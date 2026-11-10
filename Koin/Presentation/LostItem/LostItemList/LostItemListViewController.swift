//
//  LostItemListViewController.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit
import Combine

final class LostItemListViewController: UIViewController {
    
    // MARK: - Properties
    private let inputSubject = PassthroughSubject<LostItemListViewModel.Input, Never>()
    private let viewModel: LostItemListViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private lazy var searchTextField = UITextField().then {
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 40))
        $0.leftViewMode = .always
        $0.rightViewMode = .always
        $0.attributedPlaceholder = NSAttributedString(string: "검색어를 입력해주세요.", attributes: [
            .font : UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor : UIColor.appColor(.neutral500)
        ])
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.returnKeyType = .search
        $0.textColor = .appColor(.neutral800)
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.cornerRadius = 18
    }
    private let searchButton = UIButton().then {
        $0.setImage(.appImage(asset: .search)?.withTintColor(.appColor(.new500), renderingMode: .alwaysOriginal), for: .normal)
    }
    private let filterButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("필터", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardSemiBold, size: 14),
            .foregroundColor: UIColor.appColor(.neutral0)
        ]))
        configuration.image = .appImage(asset: .filter)?.withTintColor(.appColor(.neutral0), renderingMode: .alwaysOriginal).resize(to: CGSize(width: 20, height: 20))
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        configuration.imagePlacement = .trailing
        $0.configuration = configuration
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
        $0.layer.masksToBounds = false
        $0.backgroundColor = .appColor(.new500)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let lostItemKeywordCollectionView = LostItemKeywordCollectionView().then {
        $0.contentInset = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    }
    private let lostItemListTableView = LostItemListTableView()
    private let emptyLayoutGuide = UILayoutGuide()
    private let emptyView = LostItemListEmptyView().then {
        $0.isHidden = true
    }
    
    private let writeButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .appImage(asset: .pencil)?.withTintColor(.appColor(.new500), renderingMode: .alwaysOriginal).resize(to: CGSize(width: 24, height: 24))
        configuration.attributedTitle = AttributedString("글쓰기", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardMedium, size: 16),
            .foregroundColor: UIColor.appColor(.new500)
        ]))
        configuration.imagePadding = 4
        configuration.imagePlacement = .trailing
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        $0.configuration = configuration
        $0.backgroundColor = .appColor(.neutral50)
        $0.layer.borderColor = UIColor.appColor(.new500).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 21
        $0.clipsToBounds = false
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.08, x: 0, y: 8, blur: 10, spread: 0)
    }
    
    // MARK: - Initializer
    init(viewModel: LostItemListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTarget()
        setDelegate()
        title = "분실물"
        bind()
        inputSubject.send(.load)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
        inputSubject.send(.checkLogin)
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case .update(let lostItemListData):
                self.lostItemListTableView.update(lostItemListData)
            case .append(let lostItemListData):
                self.lostItemListTableView.append(lostItemListData)
            case .updateKeywords(let keywords):
                lostItemKeywordCollectionView.configure(keywords: keywords)
            }
        }.store(in: &subscriptions)
        
        lostItemListTableView.showToastPublisher.sink { [weak self] message in
            self?.showToastMessage(message: message)
        }.store(in: &subscriptions)

        lostItemListTableView.isEmptyPublisher.sink { [weak self] isEmpty in
            self?.emptyView.isHidden = !isEmpty
        }.store(in: &subscriptions)
        
        lostItemListTableView.cellTappedPublisher.sink { [weak self] id in
            self?.dismissKeyboard()
            
            self?.inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.lostItemPostEntry, .click, "분실물"))
            
            let userRepository = DefaultUserRepository(service: DefaultUserService())
            let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
            let chatRepository = DefaultLostItemRepository(service: DefaultLostItemService())
            let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
            let fetchLostItemDataUseCase = DefaultFetchLostItemDataUseCase(repository: lostItemRepository)
            let fetchLostItemListUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
            let changeLostItemStateUseCase = DefaultChangeLostItemStateUseCase(repository: lostItemRepository)
            let deleteLostItemUseCase = DefaultDeleteLostItemUseCase(repository: lostItemRepository)
            let createChatRoomUseCase = DefaultLostItemCreateChatRoomUseCase(chatRepository: chatRepository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let viewModel = LostItemDataViewModel(
                checkLoginUseCase: checkLoginUseCase,
                fetchLostItemDataUseCase: fetchLostItemDataUseCase,
                fetchLostItemListUseCase: fetchLostItemListUseCase,
                changeLostItemStateUseCase: changeLostItemStateUseCase,
                deleteLostItemUseCase: deleteLostItemUseCase,
                createChatRoomUseCase: createChatRoomUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                id: id)
            let viewController = LostItemDataViewController(viewModel: viewModel)
            viewController.delegate = self
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        lostItemListTableView.loadMoreListPublisher.sink { [weak self] in
            self?.inputSubject.send(.loadMore)
        }.store(in: &subscriptions)
        
        lostItemKeywordCollectionView.didTapSettingPublisher.sink { [weak self] in
            self?.navigateToLostItemKeyword()
            self?.inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.lostItemKeywordSetting, .click, "키워드 설정"))
        }.store(in: &subscriptions)
        lostItemKeywordCollectionView.didTapAllPublisher.sink { [weak self] in
            self?.inputSubject.send(.reset)
        }.store(in: &subscriptions)
        lostItemKeywordCollectionView.didTapKeywordPublisher.sink { [weak self] keyword in
            self?.inputSubject.send(.updateKeyword(keyword))
        }.store(in: &subscriptions)
        
    }
    
    private func setDelegate() {
        searchTextField.delegate = self
    }

    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === searchTextField {
            searchButtonTapped()
        }
        return super.textFieldShouldReturn(textField)
    }
}

extension LostItemListViewController {
    
    private func navigateToLostItemKeyword() {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let analyticsRepository = GA4AnalyticsRepository(service: GA4AnalyticsService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let subscribeKeywordUseCase = DefaultSubscribeLostItemKeywordUseCase(repository: lostItemRepository)
        let fetchKeywordSuggestionUseCase = DefaultFetchLostItemKeywordSuggestionUseCase(repository: lostItemRepository)
        let fetchMyKeywordUseCase = DefaultFetchLostItemMyKeywordUseCase(repository: lostItemRepository)
        let unsubscribeKeywordUseCase = DefaultUnsubscribeLostItemKeywordUseCase(repository: lostItemRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: analyticsRepository)
        let viewModel = LostItemKeywordViewModel(
            checkLoginUseCase: checkLoginUseCase,
            subscribeKeywordUseCase: subscribeKeywordUseCase,
            fetchKeywordSuggestionUseCase: fetchKeywordSuggestionUseCase,
            fetchMyKeywordUseCase: fetchMyKeywordUseCase,
            unsubscribeKeywordUseCase: unsubscribeKeywordUseCase,
            fetchNotiListUseCase: fetchNotiListUseCase,
            changeNotiUseCase: changeNotiUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let viewController = LostItemKeywordViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showLogin() {
        let onLeftButtonTapped: ()->Void = { [weak self] in
            self?.inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.lostItemWriteLoginRequest, .click, "닫기"))
        }
        let onRightButtonTapped: ()->Void = { [weak self] in
            self?.inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.lostItemWriteLoginRequest, .click, "로그인하기"))
            let userRepository = DefaultUserRepository(service: DefaultUserService())
            let analyticsRepository = GA4AnalyticsRepository(service: GA4AnalyticsService())
            let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
            let loginUseCase = DefaultLoginUseCase(userRepository: userRepository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: analyticsRepository)
            let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: userRepository)
            let sendDeviceTokenIfNeededUseCase = DefaultSendDeviceTokenIfNeededUseCase(
                userRepository: userRepository,
                notiRepository: notiRepository
            )
            let viewModel = LoginViewModel(
                loginUseCase: loginUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                fetchUserDataUseCase: fetchUserDataUseCase,
                sendDeviceTokenIfNeededUseCase: sendDeviceTokenIfNeededUseCase
            )
            let loginViewController = LoginViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(loginViewController, animated: true)
        }
        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .titles(
                mainTitleText: "게시글을 작성하려면\n로그인이 필요해요.",
                subTitleText: "로그인 후 글을 작성해주세요!"
            ),
            button: .buttons(
                leftButtonTitle: "닫기",
                leftButtonAction: onLeftButtonTapped,
                rightButtonTitle: "로그인하기",
                rightButtonAction: onRightButtonTapped
            )
        ))
        navigationController?.present(modalViewController, animated: true)
    }
    
    private func presentPostTypeModal() {
        weak var sheet: KoinBottomSheetController?
        let onFoundButtonTapped: () -> Void = { [weak self] in
            sheet?.dismiss { [weak self] in
                guard let self else { return }
                inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.findUserWrite, .click, "주인을 찾아요"))
                let viewController = PostLostItemViewController(viewModel: PostLostItemViewModel(type: .found))
                viewController.delegate = self
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
        let onLostButtonTapped: () -> Void = { [weak self] in
            sheet?.dismiss { [weak self] in
                guard let self else { return }
                inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.lostItemWrite, .click, "잃어버렸어요"))
                let viewController = PostLostItemViewController(viewModel: PostLostItemViewModel(type: .lost))
                viewController.delegate = self
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
        let contentView = LostItemPostOptionView(
            onFoundButtonTapped: onFoundButtonTapped,
            onLostButtonTapped: onLostButtonTapped
        )
        sheet = presentBottomSheet(contentView, configuration: .init(style: .modal(), cornerRadius: 32))
    }
}

extension LostItemListViewController: PostLostItemViewControllerDelegate {
    
    func appendData(_ newData: LostItemData) {
        lostItemListTableView.appendAtFirst(LostItemListData(from: newData))
    }
}

extension LostItemListViewController: LostItemDataViewControllerDelegate {
    
    func updateState(foundDataId id: Int) {
        lostItemListTableView.updateState(foundDataId: id)
    }
    
    func updateState(reportedDataId id: Int) {
        lostItemListTableView.updateState(reportedDataId: id)
    }
    
    func updateState(deletedId id: Int) {
        lostItemListTableView.updateState(deletedId: id)
    }
    
    func updateState(updatedId id: Int, lostItemData: LostItemData) {
        lostItemListTableView.updateState(lostItemData: lostItemData)
    }
}

extension LostItemListViewController {
    
    private func setAddTarget() {
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        writeButton.addTarget(self, action: #selector(writeButtonTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    @objc private func filterButtonTapped() {
        dismissKeyboard()
        
        inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.lostItemFilter, .click, "분실물"))
        
        let contentView = FilterBottomSheetView(
            groupModels: viewModel.filterState.toFilterGroupModels(),
            onFilterItemTapped: { [weak self] groupIndex, item in
                guard let self else { return false }
                if groupIndex == 0, item.title == "내 게시물", !viewModel.isLoggedIn {
                    showToastMessage(message: "로그인이 필요한 기능입니다.")
                    return false
                }
                return true
            },
            onApplyTapped: { [weak self] groups in
                guard let filter = FetchLostItemListRequest(from: groups) else { return }
                self?.inputSubject.send(.updateFilter(filter))
                self?.inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.lostItemFilterApply, .click, "분실물"))
            }
        )
        presentBottomSheet(contentView)
    }
    
    @objc private func writeButtonTapped() {
        self.inputSubject.send(.logEvent(LegacyEventParameter.EventLabel.Campus.LostItem.itemWrite, .click, "글쓰기"))
        viewModel.isLoggedIn ? presentPostTypeModal() : showLogin()
    }
    
    @objc private func searchButtonTapped() {
        dismissKeyboard()
        inputSubject.send(.updateTitle(searchTextField.text))
    }
}

extension LostItemListViewController {
    
    private func setLayouts() {
        view.addLayoutGuide(emptyLayoutGuide)
        [lostItemListTableView, emptyView, searchTextField, searchButton, filterButton, lostItemKeywordCollectionView, writeButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setConstraints() {
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(filterButton.snp.leading).offset(-12)
            $0.height.equalTo(36)
        }
        searchButton.snp.makeConstraints {
            $0.centerY.equalTo(searchTextField)
            $0.width.height.equalTo(34)
            $0.trailing.equalTo(searchTextField.snp.trailing).offset(-16)
        }
        filterButton.snp.makeConstraints {
            $0.height.equalTo(36)
            $0.width.equalTo(73)
            $0.centerY.equalTo(searchTextField)
            $0.trailing.equalToSuperview().offset(-24)
        }
        lostItemKeywordCollectionView.snp.makeConstraints {
            $0.height.equalTo(66)
            $0.top.equalTo(searchTextField.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
        }
        lostItemListTableView.snp.makeConstraints {
            $0.top.equalTo(lostItemKeywordCollectionView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        emptyLayoutGuide.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        emptyView.snp.makeConstraints {
            $0.edges.equalTo(emptyLayoutGuide)
        }
        writeButton.snp.makeConstraints {
            $0.width.equalTo(94)
            $0.height.equalTo(42)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
    
    private func configureView() {
        setLayouts()
        setConstraints()
        view.backgroundColor = .appColor(.neutral0)
    }
}
