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
            .font : UIFont.appFont(.pretendardRegular, size: 14),
            .foregroundColor : UIColor.appColor(.gray)
        ])
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.backgroundColor = .appColor(.neutral100)
        $0.layer.cornerRadius = 4
    }
    private let searchButton = UIButton().then {
        $0.setImage(.appImage(asset: .search), for: .normal)
        $0.tintColor = .appColor(.neutral600)
    }
    private let filterButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("필터", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardBold, size: 14),
            .foregroundColor: UIColor.appColor(.neutral600)
        ]))
        configuration.image = .appImage(asset: .filter)?.withTintColor(.appColor(.primary600), renderingMode: .alwaysTemplate).resize(to: CGSize(width: 20, height: 20))
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        configuration.imagePlacement = .trailing
        $0.configuration = configuration
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
        $0.layer.masksToBounds = false
        $0.backgroundColor = .appColor(.info200)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let lostItemListTableView = LostItemListTableView()
    
    private let writeButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .appImage(asset: .pencil)?.withTintColor(.appColor(.neutral600), renderingMode: .alwaysTemplate).resize(to: CGSize(width: 24, height: 24))
        configuration.attributedTitle = AttributedString("글쓰기", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardMedium, size: 16),
            .foregroundColor: UIColor.appColor(.neutral600)
        ]))
        configuration.imagePadding = 4
        configuration.imagePlacement = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        $0.configuration = configuration
        $0.backgroundColor = .appColor(.neutral50)
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 21
        $0.clipsToBounds = true
    }
    
    private let postLostItemLoginModalViewController = ModalViewController(width: 301, height: 208, paddingBetweenLabels: 16, title: "게시글을 작성하려면\n로그인이 필요해요.", subTitle: "로그인 후 분실물 주인을 찾아주세요!", titleColor: UIColor.appColor(.neutral700), subTitleColor: UIColor.appColor(.gray)).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
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
        inputSubject.send(.loadList)
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
            case .updateList(let lostItemListData):
                self.lostItemListTableView.update(lostItemListData)
            case .appendList(let lostItemListData):
                self.lostItemListTableView.append(lostItemListData)
            case .resetList:
                self.lostItemListTableView.reset()
            }
        }.store(in: &subscriptions)
        
        lostItemListTableView.showToastPublisher.sink { [weak self] message in
            self?.showToast(message: message)
        }.store(in: &subscriptions)
        
        lostItemListTableView.cellTappedPublisher.sink { [weak self] id in
            self?.dismissKeyboard()
            
            let userRepository = DefaultUserRepository(service: DefaultUserService())
            let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
            let chatRepository = DefaultChatRepository(service: DefaultChatService())
            let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
            let fetchLostItemDataUseCase = DefaultFetchLostItemDataUseCase(repository: lostItemRepository)
            let fetchLostItemListUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
            let changeLostItemStateUseCase = DefaultChangeLostItemStateUseCase(repository: lostItemRepository)
            let deleteLostItemUseCase = DefaultDeleteLostItemUseCase(repository: lostItemRepository)
            let createChatRoomUseCase = DefaultCreateChatRoomUseCase(chatRepository: chatRepository)
            let viewModel = LostItemDataViewModel(
                checkLoginUseCase: checkLoginUseCase,
                fetchLostItemDataUseCase: fetchLostItemDataUseCase,
                fetchLostItemListUseCase: fetchLostItemListUseCase,
                changeLostItemStateUseCase: changeLostItemStateUseCase,
                deleteLostItemUseCase: deleteLostItemUseCase,
                createChatRoomUseCase: createChatRoomUseCase,
                id: id)
            let viewController = LostItemDataViewController(viewModel: viewModel)
            viewController.delegate = self
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        lostItemListTableView.loadMoreListPublisher.sink { [weak self] in
            self?.inputSubject.send(.loadMoreList)
        }.store(in: &subscriptions)
        
        lostItemListTableView.dismissKeyBoardPublisher.sink { [weak self] in
            self?.dismissKeyboard()
        }.store(in: &subscriptions)
    }
    
    private func setDelegate() {
        searchTextField.delegate = self
    }
}

extension LostItemListViewController {
    
    private func showLogin() {
        let onRightButtonTapped = { [weak self] in
            let userService = DefaultUserService()
            let logAnalyticsService = GA4AnalyticsService()
            let userRepository = DefaultUserRepository(service: userService)
            let analyticsRepository = GA4AnalyticsRepository(service: logAnalyticsService)
            let loginUseCase = DefaultLoginUseCase(userRepository: userRepository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: analyticsRepository)
            let loginViewModel = LoginViewModel(loginUseCase: loginUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
            let loginViewController = LoginViewController(viewModel: loginViewModel)
            self?.navigationController?.pushViewController(loginViewController, animated: true)
        }
        let loginModalViewController = ModalViewControllerB(onRightButtonTapped: onRightButtonTapped, width: 301, height: 208, paddingBetweenLabels: 16, title: "게시글을 작성하려면\n로그인이 필요해요.", subTitle: "로그인 후 글을 작성해주세요!", titleColor: UIColor.appColor(.neutral700), subTitleColor: UIColor.appColor(.gray)).then {
            $0.modalPresentationStyle = .overFullScreen
            $0.modalTransitionStyle = .crossDissolve
        }
        navigationController?.present(loginModalViewController, animated: true)
    }
    
    private func presentPostTypeModal() {
        let onFoundButtonTapped = { [weak self] in
            guard let self else { return }
            dismissView()
            let viewController = PostLostItemViewController(viewModel: PostLostItemViewModel(type: .found))
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        }
        let onLostButtonTapped = { [weak self] in
            guard let self else { return }
            dismissView()
            let viewController = PostLostItemViewController(viewModel: PostLostItemViewModel(type: .lost))
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        }
        let postOptionViewController = LostItemPostOptionController(
            onFoundButtonTapped: onFoundButtonTapped,
            onLostButtonTapped: onLostButtonTapped
        )
        let bottomSheetViewController = BottomSheetViewController(
            contentViewController: postOptionViewController,
            defaultHeight: 191 + UIApplication.bottomSafeAreaHeight(),
            cornerRadius: 32
        )
        bottomSheetViewController.modalTransitionStyle = .crossDissolve
        navigationController?.present(bottomSheetViewController, animated: true)
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
        
        let filterViewController = LostItemListFilterViewController(
            isLoggedIn: self.viewModel.isLoggedIn,
            filterState: self.viewModel.filterState,
            onApplyFilterButtonTapped: { [weak self] filter in
                self?.dismissView()
                self?.inputSubject.send(.updateFilter(filter: filter))
            }
        )
        let bottomSheetViewController = BottomSheetViewController(
            contentViewController: filterViewController,
            defaultHeight: 627 + UIApplication.bottomSafeAreaHeight(),
            cornerRadius: 32)
        bottomSheetViewController.modalTransitionStyle = .crossDissolve
        navigationController?.present(bottomSheetViewController, animated: true)
    }
    
    @objc private func writeButtonTapped() {
        if viewModel.isLoggedIn {
            self.presentPostTypeModal()
        } else {
            self.showLogin()
        }
    }
    
    @objc private func searchButtonTapped() {
        dismissKeyboard()
        inputSubject.send(.updateTitle(title: searchTextField.text))
    }
}

extension LostItemListViewController {
    
    private func setLayouts() {
        [lostItemListTableView, searchTextField, searchButton, filterButton, writeButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setConstraints() {
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(filterButton.snp.leading).offset(-12)
            $0.height.equalTo(40)
        }
        searchButton.snp.makeConstraints {
            $0.centerY.equalTo(searchTextField)
            $0.width.height.equalTo(34)
            $0.trailing.equalTo(searchTextField.snp.trailing).offset(-16)
        }
        filterButton.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.width.equalTo(73)
            $0.centerY.equalTo(searchTextField)
            $0.trailing.equalToSuperview().offset(-24)
        }
        lostItemListTableView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
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
