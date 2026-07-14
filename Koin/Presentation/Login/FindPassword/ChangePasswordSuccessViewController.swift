//
//  ChangePasswordSuccessViewController.swift
//  koin
//
//  Created by 김나훈 on 6/19/25.
//

import Combine
import UIKit

final class ChangePasswordSuccessViewController: UIViewController {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let circleImageView = UIImageView().then {
        $0.image = UIImage(named: "checkFilledCircle")
    }
    
    private let messageLabel = UILabel().then {
        $0.text = "비밀번호 변경 완료"
    }
    private let subMessageLabel = UILabel().then {
        $0.text = "비밀번호가 변경되었습니다.\n새로운 비밀번호로 로그인 부탁드립니다."
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    private let goLoginButton = StateButton(font: UIFont.appFont(.pretendardBold, size: 15)).then {
        $0.setState(state: .usable)
        $0.setTitle("로그인 화면 바로가기", for: .normal)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "비밀번호 찾기"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupUI()
        bind()
        goLoginButton.addTarget(self, action: #selector(goLoginButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    // MARK: - Bind
    
    private func bind() {
       
    }
}

extension ChangePasswordSuccessViewController {
    @objc private func goLoginButtonTapped() {
        let homeViewController = makeHomeTabBarController()
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
        let viewControllers = [homeViewController, loginViewController]
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    private func makeHomeTabBarController() -> HomeTabBarController {
        let homeViewController = makeHomeHostingController()
        let categoryViewController = makeCategoryHostingController()
        let noticeViewController = makeNoticeListViewController()
        let profileViewController = makeProfileHostingController()
        
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let checkHasUnreadNotificationHistoryUseCase = DefaultCheckHasUnreadNotificationHistoryUseCase(repository: DefaultNotificationHistoryRepository(service: DefaultNotificationHistoryService()))
        let viewModel = HomeTabBarViewModel(
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            checkHasUnreadNotificationHistoryUseCase: checkHasUnreadNotificationHistoryUseCase
        )

        return HomeTabBarController(
            items: [
                .init(viewController: homeViewController, tab: .home),
                .init(viewController: categoryViewController, tab: .category),
                .init(viewController: noticeViewController, tab: .board),
                .init(viewController: profileViewController, tab: .profile)
            ],
            viewModel: viewModel
        )
    }

    private func makeHomeHostingController() -> UIViewController {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let coreRepository = DefaultCoreRepository(service: DefaultCoreService())
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let diningRepository = DefaultDiningRepository(diningService: DefaultDiningService(), shareService: KakaoShareService())
        let homeRepository = DefaultHomeRepository(service: DefaultHomeService())

        let fetchHomeHeaderUseCase = DefaultFetchHomeHeaderUseCase(homeRepository: homeRepository, userRepository: userRepository)
        let fetchHomeDiningListUseCase = DefaultFetchHomeDiningListUseCase(
            fetchDiningListUseCase: DefaultFetchDiningListUseCase(diningRepository: diningRepository),
            fetchCoopShopListUseCase: DefaultFetchCoopShopListUseCase(diningRepository: diningRepository),
            dateProvider: DefaultDateProvider()
        )
        let fetchCountsUseCase = DefaultFetchNewHomeCountsUseCase(
            shopRepository: shopRepository,
            callvanRepository: callVanRepository
        )
        let checkVersionUseCase = DefaultCheckVersionUseCase(coreRepository: coreRepository)
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: userRepository)
        let SendDeviceTokenIfNeededUseCase = DefaultSendDeviceTokenIfNeededUseCase(
            userRepository: userRepository,
            notiRepository: notiRepository
        )
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        
        let viewModel = NewHomeViewModel(
            fetchHomeHeaderUseCase: fetchHomeHeaderUseCase,
            fetchHomeDiningListUseCase: fetchHomeDiningListUseCase,
            fetchCountsUseCase: fetchCountsUseCase,
            checkVersionUseCase: checkVersionUseCase,
            checkLoginUseCase: DefaultCheckLoginUseCase(userRepository: userRepository),
            fetchUserDataUseCase: fetchUserDataUseCase,
            sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            fetchBannerUseCase: DefaultFetchBannerUseCase(coreRepository: coreRepository)
        )
        let homeView = HomeView(viewModel: viewModel)
        return HomeHostingController(rootView: homeView)
    }
    
    private func makeCategoryHostingController() -> UIViewController {
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let categoryRootView = CategoryView(viewModel: CategoryViewModel(logAnalyticsEventUseCase: logAnalyticsEventUseCase))
        return CategoryHostingController(rootView: categoryRootView)
    }
    
    private func makeNoticeListViewController() -> UIViewController {
        let service = DefaultNoticeService()
        let repository = DefaultNoticeListRepository(service: service)
        let fetchArticleListUseCase = DefaultFetchNoticeArticlesUseCase(noticeListRepository: repository)
        let fetchMyKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(
            repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
        )
        let viewModel = NoticeListViewModel(
            fetchNoticeArticlesUseCase: fetchArticleListUseCase,
            fetchMyKeywordUseCase: fetchMyKeywordUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        return NoticeListViewController(viewModel: viewModel)
    }
    
    private func makeProfileHostingController() -> UIViewController {
        let timeTableRepository = DefaultTimetableRepository(service: DefaultTimetableService())
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let deleteDeviceTokenUseCase = DefaultDeleteDeviceTokenUseCase(repository: DefaultNotiRepository(service: DefaultNotiService()))
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let fetchMainFrameUseCase = DefaultFetchMainFrameUseCase(
            fetchFramesUseCase: DefaultFetchFramesUseCase(timetableRepository: timeTableRepository),
            fetchFrameUseCase: DefaultFetchFrameUseCase(timetableRepository: timeTableRepository),
            fetchLectureUseCase: DefaultFetchLectureUseCase(timetableRepository: timeTableRepository)
        )
        let profileViewModel = ProfileViewModel(
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            deleteDeviceTokenUseCase: deleteDeviceTokenUseCase,
            fetchUserDataUseCase: fetchUserDataUseCase,
            fetchMainFrameUseCase: fetchMainFrameUseCase
        )
        let profileView = ProfileView(viewModel: profileViewModel)
        return ProfileHostingController(rootView: profileView)
    }
}

extension ChangePasswordSuccessViewController {
    
    private func setupLayOuts() {
        [circleImageView, messageLabel, subMessageLabel, goLoginButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        circleImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
            $0.size.equalTo(55)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(circleImageView.snp.bottom).offset(36)
            $0.centerX.equalToSuperview()
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        goLoginButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(36)
            $0.horizontalEdges.equalToSuperview().inset(48)
            $0.width.equalTo(294)
            $0.height.equalTo(44)
        }
    }
    
    private func setupComponents() {
        messageLabel.font = UIFont.appFont(.pretendardBold, size: 24)
        messageLabel.textColor = UIColor.appColor(.primary500)
        subMessageLabel.font = UIFont.appFont(.pretendardMedium, size: 16)
        subMessageLabel.textColor = UIColor.appColor(.gray)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
