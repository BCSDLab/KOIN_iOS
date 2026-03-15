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
    
    // MARK: - UI Components
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
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case let .didCheckLoginToParticapate(isLoggedIn):
                showBottomSheet(isLoggedIn: isLoggedIn, state: .참여하기)
            case let .resetList(posts):
                callVanListCollectionView.reset(posts: posts)
            case let .appendList(posts):
                callVanListCollectionView.append(posts: posts)
            case .updateBellWithNotification:
                configureRightBarButton(alert: true)
            }
        }.store(in: &subscriptions)
        
        callVanListCollectionView.mainButtonTappedPublisher.sink { [weak self] postId, state in
            self?.cellButtonTapped(postId: postId, state: state)
        }.store(in: &subscriptions)
        callVanListCollectionView.subButtonTappedPublisher.sink { [weak self] postId, state in
            self?.cellButtonTapped(postId: postId, state: state)
        }.store(in: &subscriptions)
        callVanListCollectionView.chatButtonTappedPublisher.sink { [weak self] postId in
            self?.chatButtonTapped(postId: postId)
        }.store(in: &subscriptions)
        callVanListCollectionView.callButtonTappedPublisher.sink { [weak self] in
            self?.callButtonTapped()
        }.store(in: &subscriptions)
        callVanListCollectionView.postTappedPublisher.sink { [weak self] postId in
            self?.navigateToCallVanData(postId)
        }.store(in: &subscriptions)
        
        callVanListCollectionView.loadMoreListPublisher.sink { [weak self] in
            self?.inputSubject.send(.loadMoreList)
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
    }
    
    @objc private func writeButtonTapped() {
        let viewController = CallVanPostViewController(viewModel: CallVanPostViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        let contentViewController = CallVanListFilterViewController(
            filter: viewModel.filterState,
            onApplyButtonTapped: { [weak self] filterState in
                guard let self else { return }
                inputSubject.send(.updateFilterState(filterState))
            }
        )
        let bottomSheetViewController = BottomSheetViewController(contentViewController: contentViewController, defaultHeight: 605 + view.safeAreaInsets.bottom)
        present(bottomSheetViewController, animated: true)
    }
    
    @objc private func searchButtonTapped() {
        inputSubject.send(.updateFilterTitle(searchTextField.text))
        dismissKeyboard()
    }
}

extension CallVanListViewController {
    
    private func setDelegates() {
        searchTextField.delegate = self
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonTapped()
        return true
    }
}

extension CallVanListViewController {
    
    private func navigateToCallVanData(_ postId: Int) {
        let fetchCallVanDataUseCase = MockFetchCallVanDataUseCase()
        let viewModel = CallVanDataViewModel(postId: postId, fetchCallVanDataUseCase: fetchCallVanDataUseCase)
        let viewController = CallVanDataViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showBottomSheet(isLoggedIn: Bool?, state: CallVanState) {
        let onMainButtonTapped: ()->Void
        var defaultHeight: CGFloat = 195 + view.safeAreaInsets.bottom
        switch (isLoggedIn, state) {
        case (true, .참여하기):
            onMainButtonTapped = {}
        case (false, .참여하기):
            onMainButtonTapped = {}
        case (_ , .참여취소):
            onMainButtonTapped = {}
        case (_ , .마감하기):
            onMainButtonTapped = {}
        case (_ , .재모집):
            onMainButtonTapped = {}
        case (_, .이용완료):
            onMainButtonTapped = {}
            defaultHeight = 255 + view.safeAreaInsets.bottom
        default:
            return
        }
        let contentViewController = CallVanBottomSheetViewController(isLoggedIn: isLoggedIn, state: state, onMainButtonTapped: onMainButtonTapped)
        let bottomSheetViewController = BottomSheetViewController(contentViewController: contentViewController, defaultHeight: defaultHeight)
        bottomSheetViewController.modalTransitionStyle = .crossDissolve
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        present(bottomSheetViewController, animated: true)
    }
    
    private func cellButtonTapped(postId: Int, state: CallVanState) {
        switch state {
        case .참여하기:
            inputSubject.send(.checkLoginToParticapate)
        case .참여취소, .마감하기, .재모집, .이용완료:
            showBottomSheet(isLoggedIn: nil, state: state)
        case .모집마감:
            break
        }
        
    }
    private func chatButtonTapped(postId: Int) {
        let viewModel = CallVanChatViewModel(postId: postId)
        let viewController = CallVanChatViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
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
