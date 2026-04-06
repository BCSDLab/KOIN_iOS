//
//  CallVanListViewController.swift
//  koin
//
//  Created by 홍기정 on 3/3/26.
//

import UIKit
import Combine

final class CallVanListViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CallVanListViewModel
    private let inputSubject = PassthroughSubject<CallVanListViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var didSwipeToPop = false
    
    // MARK: - UI Components
    private let refreshControl = UIRefreshControl()
    private let searchTextField = UITextField()
    private let searchButton = UIButton()
    private let filterButton = UIButton()
    private let callVanListCollectionView = CallVanListCollectionView()
    private let writeButton = UIButton()
    
    // MARK: - Initialzier
    init(viewModel: CallVanListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "콜밴팟"
        configureView()
        configureRightBarButton()
        configureNavigationBar(style: .empty)
        hideKeyboardWhenTappedAround()
        setAddTargets()
        setDelegates()
        bind()
        inputSubject.send(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.viewWillAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let didSwipeToPop = (navigationController as? CustomNavigationController)?.didSwipeToPop {
            self.didSwipeToPop = didSwipeToPop
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            let category: EventParameter.EventCategory = didSwipeToPop ? .swipe : .click
            inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanBack, category: category, value: ""))
        }
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case let .resetList(posts):
                callVanListCollectionView.reset(posts: posts)
            case let .appendList(posts):
                callVanListCollectionView.append(posts: posts)
            case let .updateListItem(callVanListPost, postId):
                callVanListCollectionView.updateItem(callVanListPost, postId)
            case let .deleteListItem(postId):
                callVanListCollectionView.deleteItem(postId: postId)
            case let .updateBell(alert):
                configureRightBarButton(alert: alert)
            case let .showToast(message):
                showToastMessage(message: message, bottomInset: 75)
            case .showReportedModal:
                showReportedModal()
            }
            refreshControl.endRefreshing()
        }.store(in: &subscriptions)
        
        callVanListCollectionView.mainButtonTappedPublisher.receive(on: DispatchQueue.main).sink { [weak self] postId, state in
            self?.cellButtonTapped(postId: postId, state: state)
        }.store(in: &subscriptions)
        callVanListCollectionView.subButtonTappedPublisher.receive(on: DispatchQueue.main).sink { [weak self] postId, state in
            self?.cellButtonTapped(postId: postId, state: state)
        }.store(in: &subscriptions)
        callVanListCollectionView.chatButtonTappedPublisher.receive(on: DispatchQueue.main).sink { [weak self] postId in
            self?.chatButtonTapped(postId: postId)
        }.store(in: &subscriptions)
        callVanListCollectionView.callButtonTappedPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.callButtonTapped()
        }.store(in: &subscriptions)
        callVanListCollectionView.postTappedPublisher.receive(on: DispatchQueue.main).sink { [weak self] postId in
            self?.navigateToCallVanData(postId)
        }.store(in: &subscriptions)
        
        callVanListCollectionView.loadMoreListPublisher.sink { [weak self] in
            self?.inputSubject.send(.loadMoreList)
        }.store(in: &subscriptions)
        callVanListCollectionView.didScrollPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.dismissKeyboard()
        }.store(in: &subscriptions)
    }
}

extension CallVanListViewController {
    
    private func configureRightBarButton(alert: Bool = false) {
        let image = alert ? UIImage.appImage(asset: .bellNotification) : UIImage.appImage(asset: .bell)
        let bellButton = UIBarButtonItem(image: image?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(bellButtonTapped))
        navigationItem.rightBarButtonItem = bellButton
    }
    
    @objc private func bellButtonTapped() {
        dismissKeyboard()
        
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let fetchCallVanNotificationListUseCase = DefaultFetchCallVanNotificationListUseCase(repository: callVanRepository)
        let postNotificationReadUseCase = DefaultPostNotificationReadUseCase(repository: callVanRepository)
        let postAllNotificationsReadUseCase = DefaultPostAllNotificationsReadUseCase(repository: callVanRepository)
        let deleteNotificationUseCase = DefaultDeleteNotificationUseCase(repository: callVanRepository)
        let deleteAllNotificationsUseCase = DefaultDeleteAllNotificationsUseCase(repository: callVanRepository)
        let viewModel = CallVanNotificationViewModel(
            fetchCallVanNotificationListUseCase: fetchCallVanNotificationListUseCase,
            postNotificationReadUseCase: postNotificationReadUseCase,
            postAllNotificationsReadUseCase: postAllNotificationsReadUseCase,
            deleteNotificationUseCase: deleteNotificationUseCase,
            deleteAllNotificationsUseCase: deleteAllNotificationsUseCase)
        let viewController = CallVanNotificationViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CallVanListViewController {
    
    private func setAddTargets() {
        writeButton.addTarget(self, action: #selector(writeButtonTapped), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        inputSubject.send(.refresh)
    }
    
    @objc private func writeButtonTapped() {
        inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanCreate, category: .click, value: ""))
        if viewModel.isLoggedIn {
            navigateToPost()
        } else {
            showLoginToPostBottomSheet()
        }
    }
    
    private func navigateToPost() {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let postCallVanDataUseCase = DefaultPostCallVanDataUseCase(repository: callVanRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = CallVanPostViewModel(
            postCallVanDataUseCase: postCallVanDataUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let viewController = CallVanPostViewController(viewModel: viewModel)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        let height = min(view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom, 707)
        let contentViewController = CallVanListFilterViewController(
            filter: viewModel.filterState,
            onApplyButtonTapped: { [weak self] filterState in
                guard let self else { return }
                inputSubject.send(.updateFilterState(filterState))
                inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanFilterApply, category: .click, value: ""))
            },
            isLoggedIn: viewModel.isLoggedIn,
            height: height
        )
        let bottomSheetViewController = BottomSheetViewController(contentViewController: contentViewController, defaultHeight: height + view.safeAreaInsets.bottom)
        bottomSheetViewController.modalTransitionStyle = .crossDissolve
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        present(bottomSheetViewController, animated: false)
        inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanFilter, category: .click, value: ""))
    }
    
    @objc private func searchButtonTapped() {
        inputSubject.send(.updateFilterTitle(searchTextField.text))
        dismissKeyboard()
    }
}

extension CallVanListViewController: CallVanPostViewControllerDelegate {
    
    func appendPostData(_ postData: CallVanListPost) {
        callVanListCollectionView.prepend(post: postData)
    }
}

extension CallVanListViewController {
    
    private func setDelegates() {
        searchTextField.delegate = self
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanSsearch, category: .click, value: ""))
        return true
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        super.textFieldShouldReturn(textField)
        searchButtonTapped()
        return true
    }
}

extension CallVanListViewController {
    
    private func navigateToCallVanData(_ postId: Int) {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let fetchCallVanDataUseCase = DefaultFetchCallVanDataUseCase(repository: callVanRepository)
        let fetchCallVanNotificationListUseCase = DefaultFetchCallVanNotificationListUseCase(repository: callVanRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = CallVanDataViewModel(
            postId: postId,
            fetchCallVanDataUseCase: fetchCallVanDataUseCase,
            fetchCallVanNotificationListUseCase: fetchCallVanNotificationListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let viewController = CallVanDataViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showBottomSheet(state: CallVanState, postId: Int) {
        let onMainButtonTapped: ()->Void
        var onCloseButtonTapped: (()->Void)? = nil
        var defaultHeight: CGFloat = 195 + view.safeAreaInsets.bottom
        switch state {
        case .참여하기:
            onMainButtonTapped = { [weak self] in
                self?.inputSubject.send(.participate(postId))
                self?.inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanJoin, category: .click, value: "예"))
            }
            onCloseButtonTapped = { [weak self] in
                self?.inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanJoin, category: .click, value: "아니요"))
            }
        case .참여취소:
            onMainButtonTapped = { [weak self] in
                self?.inputSubject.send(.quit(postId))
                self?.inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanJoinCancel, category: .click, value: "예"))
            }
            onCloseButtonTapped = { [weak self] in
                self?.inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanJoinCancel, category: .click, value: "아니요"))
            }
        case .마감하기:
            onMainButtonTapped = { [weak self] in
                self?.inputSubject.send(.close(postId))
            }
        case .재모집:
            onMainButtonTapped = { [weak self] in
                self?.inputSubject.send(.reopen(postId))
            }
        case .이용완료:
            onMainButtonTapped = { [weak self] in
                self?.inputSubject.send(.complete(postId))
            }
            defaultHeight = 255 + view.safeAreaInsets.bottom
        default:
            return
        }
        let contentViewController = CallVanBottomSheetViewController(state: state, onMainButtonTapped: onMainButtonTapped, onCloseButtonTapped: onCloseButtonTapped)
        let bottomSheetViewController = BottomSheetViewController(contentViewController: contentViewController, defaultHeight: defaultHeight)
        bottomSheetViewController.modalTransitionStyle = .crossDissolve
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        present(bottomSheetViewController, animated: false)
    }
    
    private func showLoginToPostBottomSheet() {
        let onMainButtonTapped: ()->Void = { [weak self] in
            self?.navigateToLogin()
        }
        let defaultHeight: CGFloat = 195 + view.safeAreaInsets.bottom
        let contentViewController = CallVanBottomSheetViewController(titleText: "콜밴팟을 모집하려면 로그인이 필요해요.", subTitleLabel: nil, mainButtonText: "로그인하기", closeButtonText: "닫기", onMainButtonTapped: onMainButtonTapped)
        let bottomSheetViewController = BottomSheetViewController(contentViewController: contentViewController, defaultHeight: defaultHeight)
        bottomSheetViewController.modalTransitionStyle = .crossDissolve
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        present(bottomSheetViewController, animated: false)
    }
    
    private func showLoginToParticipateBottomSheet() {
        let onMainButtonTapped: ()->Void = { [weak self] in
            self?.navigateToLogin()
        }
        let defaultHeight: CGFloat = 195 + view.safeAreaInsets.bottom
        let contentViewController = CallVanBottomSheetViewController(titleText: "콜밴팟에 참여하려면 로그인이 필요해요.", subTitleLabel: nil, mainButtonText: "로그인하기", closeButtonText: "닫기", onMainButtonTapped: onMainButtonTapped)
        let bottomSheetViewController = BottomSheetViewController(contentViewController: contentViewController, defaultHeight: defaultHeight)
        bottomSheetViewController.modalTransitionStyle = .crossDissolve
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        present(bottomSheetViewController, animated: false)
    }
    
    private func cellButtonTapped(postId: Int, state: CallVanState) {
        switch state {
        case .참여하기:
            if viewModel.isLoggedIn {
                showBottomSheet(state: .참여하기, postId: postId)
            } else {
                showLoginToParticipateBottomSheet()
            }
        case .참여취소, .마감하기, .재모집, .이용완료:
            showBottomSheet(state: state, postId: postId)
        case .모집마감:
            break
        }
        
    }
    private func chatButtonTapped(postId: Int) {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let coreRepository = DefaultCoreRepository(service: DefaultCoreService())
        let fetchCallVanChatUseCase = DefaultFetchCallVanChatUseCase(repository: callVanRepository)
        let postCallVanChatUseCase = DefaultPostCallVanChatUseCase(repository: callVanRepository)
        let fetchCallVanDataUseCase = DefaultFetchCallVanDataUseCase(repository: callVanRepository)
        let uploadFileUseCase = DefaultUploadFileUseCase(coreRepository: coreRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = CallVanChatViewModel(
            postId: postId,
            fetchCallVanChatUseCase: fetchCallVanChatUseCase,
            postCallVanChatUseCase: postCallVanChatUseCase,
            fetchCallVanDataUseCase: fetchCallVanDataUseCase,
            uploadFileUseCase: uploadFileUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let viewController = CallVanChatViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
        inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanChat, category: .click, value: ""))
    }
    
    private func callButtonTapped() {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        
        let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
        let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
        let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let viewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            selectedId: 11)
        let shopViewController = ShopViewController(viewModel: viewModel)
        navigationController?.pushViewController(shopViewController, animated: true)
        inputSubject.send(.logEvent(label: EventParameter.EventLabel.Campus.callvanCall, category: .click, value: ""))
    }
    
    private func showReportedModal() {
        let modalViewController = CallVanModalViewController(title: "이용 정지", description: "해당 계정은 콜밴팟 기능을\n사용할 수 없습니다.")
        modalViewController.modalPresentationStyle = .overFullScreen
        present(modalViewController, animated: false)
    }
}

extension CallVanListViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral0)
        
        searchTextField.do {
            $0.attributedPlaceholder = NSAttributedString(
                string: "검색어를 입력해주세요.",
                attributes: [
                    .font : UIFont.appFont(.pretendardRegular, size: 14),
                    .foregroundColor : UIColor.appColor(.neutral600)
                ])
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
            
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
            $0.leftViewMode = .always
            
            $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 40))
            $0.rightViewMode = .always
            
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 4
        }
        
        searchButton.do {
            $0.setImage(UIImage.appImage(asset: .search), for: .normal)
        }
        
        filterButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString("필터", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardBold, size: 14),
                .foregroundColor : UIColor.ColorSystem.Primary.purple1300
            ]))
            configuration.image = UIImage.appImage(asset: .filter)?
                .withTintColor(
                    UIColor.ColorSystem.Primary.purple1300,
                    renderingMode: .alwaysTemplate
                )
                .resize(to: CGSize(width: 20, height: 20))
            configuration.imagePlacement = .trailing
            configuration.imagePadding = 6.5
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.configuration = configuration
            
            $0.backgroundColor = UIColor.appColor(.new100)
            $0.layer.cornerRadius = 17
            $0.layer.applySketchShadow(color: .black, alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        }
        
        writeButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.image = UIImage.appImage(asset: .callVanCar)
            configuration.attributedTitle = AttributedString("모집하기", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardMedium, size: 16),
                .foregroundColor : UIColor.ColorSystem.Primary.purple800
            ]))
            configuration.imagePadding = 8
            configuration.imagePlacement = .leading
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.configuration = configuration
            $0.backgroundColor = UIColor.appColor(.neutral50)
            $0.layer.borderColor = UIColor.appColor(.new400).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 21
            $0.layer.applySketchShadow(color: .black, alpha: 0.08, x: 0, y: 4, blur: 10, spread: 0)
        }
        
        callVanListCollectionView.do {
            $0.refreshControl = refreshControl
        }
    }
    private func setUpLayouts() {
        [searchTextField, searchButton, filterButton, callVanListCollectionView, writeButton].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        searchTextField.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(filterButton.snp.leading).offset(-12)
        }
        searchButton.snp.makeConstraints {
            $0.centerY.equalTo(searchTextField)
            $0.trailing.equalTo(searchTextField).offset(-16)
        }
        filterButton.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.centerY.equalTo(searchTextField)
            $0.trailing.equalToSuperview().offset(-24)
        }
        callVanListCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        writeButton.snp.makeConstraints {
            $0.height.equalTo(42)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-22)
        }
    }
}
