import UIKit
import PhotosUI
import Combine

@MainActor
final class AppCoordinator: RootCoordinator {

    // MARK: - Route
    enum Route {
        case splash
        case forceUpdate
        case forceUpdateModal(onOpenStoreButtonTapped: () -> Void, onCancelButtonTapped: () -> Void)
        case forceModifyUser
        case error
    }

    // MARK: - Properties
    var children: [any ChildCoordinator] = []
    var navigationController: CustomNavigationController

    private let appLaunchPresentationUseCase: AppLaunchPresentationUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    var pickerCompletion: ((UIImage) -> Void)?
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Init
    init(
        navigationController: CustomNavigationController,
        appLaunchPresentationUseCase: AppLaunchPresentationUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.navigationController = navigationController
        self.appLaunchPresentationUseCase = appLaunchPresentationUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        bind()
    }

    // MARK: - Start
    func start() async {
        let viewController = makeViewController(route: .splash)
        navigationController.setViewControllers([viewController], animated: false)
        
        let presentation = await appLaunchPresentationUseCase.execute()
        switch presentation {
        case .none:
            startHome(shouldPresentBanner: true)
        case .forceModifyUser:
            presentForceModifyUser { [weak self] in
                self?.startHome(shouldPresentBanner: false)
            }
        case .forceUpdate(let requiredVersion):
            logAnalyticsEventUseCase.execute(
                label: EventParameter.EventLabel.ForceUpdate.forcedUpdatePageView,
                category: .pageView,
                value: requiredVersion
            )
            presentForceUpdate { [weak self] in
                self?.startHome(shouldPresentBanner: false)
            }
        }
    }

    func start<C: ChildCoordinator>(_ type: C.Type, route: C.Route) {
        let child = type.init(parentCoordinator: self, navigationController: navigationController)
        children.append(child)
        child.start(route: route)
    }
}

extension AppCoordinator {
    
    private func bind() {
        navigationController.didPopViewControllerPublisher
            .sink { [weak self] poppedViewController in
                self?.children.removeAll(where: { $0.rootViewController === poppedViewController })
            }
            .store(in: &subscriptions)

        NetworkService.shared.serverErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.presentErrorViewController()
            }.store(in: &subscriptions)
    }
    
    @objc private func presentErrorViewController() {
        if let presentedViewController = navigationController.presentedViewController,
           presentedViewController is ErrorViewController || presentedViewController is ForceUpdateViewController || presentedViewController is ForceModifyUserViewController {
            return
        }
        
        let viewController = makeViewController(route: .error)
        viewController.modalPresentationStyle = .overFullScreen
        
        if let presentedViewController = navigationController.presentedViewController {
            presentedViewController.dismiss(animated: true) { [weak self] in
                self?.navigationController.present(viewController, animated: true)
            }
        } else {
            navigationController.present(viewController, animated: true)
        }
    }
}

extension AppCoordinator {
    
    private func startHome(shouldPresentBanner: Bool) { // TODO: 홈코디네이터 연결
        let viewController = makeHomeTabbarController(shouldPresentBanner: shouldPresentBanner)
        navigationController.setViewControllers([viewController], transition: .fade)
    }
    
    private func presentForceUpdate(completion: @escaping ()->Void) {
        let viewController = makeViewController(route: .forceUpdate)
        viewController.modalPresentationStyle = .overFullScreen
        navigationController.present(viewController, animated: true, completion: completion)
    }
    
    private func presentForceModifyUser(completion: @escaping ()->Void) {
        let viewController = makeViewController(route: .forceModifyUser)
        viewController.modalPresentationStyle = .overFullScreen
        navigationController.present(viewController, animated: true, completion: completion)
    }
}

// MARK: - ForceUpdateViewControllerCoordinator

extension AppCoordinator: ForceUpdateViewControllerCoordinator {
    
    func updateButtonTapped() {
        openAppStore()
    }
    
    func errorCheckButtonTapped(
        presentOn presenter: UIViewController,
        onOpenStoreButtonTapped: @escaping () -> Void,
        onCancelButtonTapped: @escaping () -> Void
    ) {
        let viewController = makeViewController(route: .forceUpdateModal(
            onOpenStoreButtonTapped: onOpenStoreButtonTapped,
            onCancelButtonTapped: onCancelButtonTapped
        ))
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        presenter.present(viewController, animated: true)
    }
    
    private func openAppStore() {
        guard let url = URL(string: "https://apps.apple.com/app/id6504234838") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - ErrorViewControllerCoordinator

extension AppCoordinator: ErrorViewControllerCoordinator {
    func homeButtonTapped() {
        navigationController.dismiss(animated: true)
        Task {
            await start()
        }
    }
}

// MARK: - ForceModifyUserViewControllerCoordinator

extension AppCoordinator: ForceModifyUserViewControllerCoordinator {
    
    func modifyUserButtonTapped() { // TODO: Setting Coordinator
        navigationController.dismiss(animated: true) { [weak self] in
            let modifyUseCase = DefaultModifyUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
            let fetchDeptListUseCase = DefaultFetchDeptListUseCase(timetableRepository: DefaultTimetableRepository(service: DefaultTimetableService()))
            let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
            let checkDuplicatedNicknameUseCase = DefaultCheckDuplicatedNicknameUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let viewModel = ChangeMyProfileViewModel(
                modifyUseCase: modifyUseCase,
                fetchDeptListUseCase: fetchDeptListUseCase,
                fetchUserDataUseCase: fetchUserDataUseCase,
                checkDuplicatedNicknameUseCase: checkDuplicatedNicknameUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase
            )
            let viewController = ChangeMyProfileViewController(
                viewModel: viewModel,
                userType: .student
            )
            self?.navigationController.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - MakeViewController

extension AppCoordinator {
    
    private func makeViewController(route: Route) -> UIViewController {
        switch route {
        case .splash:
            return makeSplashViewController()
        case .error:
            return makeErrorViewController(coordinator: self)
        case .forceModifyUser:
            return makeForceModifyUserViewController(coordinator: self)
        case .forceUpdate:
           return makeForceUpdateViewController(coordinator: self)
        case .forceUpdateModal(let onOpenStoreButtonTapped, let onCancelButtonTapped):
            return makeForceUpdateModalViewController(
                onOpenStoreButtonTapped: onOpenStoreButtonTapped,
                onCancelButtonTapped: onCancelButtonTapped
            )
        }
    }
    
    private func makeSplashViewController() -> UIViewController {
        return SplashViewController()
    }
    
    private func makeErrorViewController(coordinator: ErrorViewControllerCoordinator) -> UIViewController {
        return ErrorViewController(coordinator: coordinator)
    }
    
    private func makeForceModifyUserViewController(coordinator: ForceModifyUserViewControllerCoordinator) -> UIViewController {
        return ForceModifyUserViewController(coordinator: coordinator)
    }
    
    private func makeForceUpdateViewController(coordinator: ForceUpdateViewControllerCoordinator) -> UIViewController {
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = ForceUpdateViewModel(logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        return ForceUpdateViewController(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }
    
    private func makeForceUpdateModalViewController(
        onOpenStoreButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: @escaping ()->Void
    ) -> UIViewController {
        return ForceUpdateModalViewController(
            onOpenStoreButtonTapped: onOpenStoreButtonTapped,
            onCancelButtonTapped: onCancelButtonTapped
        )
    }
}

// MARK: - Home Coordinator

extension AppCoordinator {
    
    private func makeHomeTabbarController(shouldPresentBanner: Bool) -> HomeTabbarController {
        let homeRootView = makeHomeView(shouldPresentBanner: shouldPresentBanner)
        let homeViewController = HomeHostingController(rootView: homeRootView)

        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let categoryRootView = CategoryView(viewModel: CategoryViewModel(logAnalyticsEventUseCase: logAnalyticsEventUseCase))
        let categoryViewController = CategoryHostingController(rootView: categoryRootView)

        let noticeViewController = makeNoticeListViewController()
        let profileViewController = UIViewController()
        
        let viewModel = HomeTabbarViewModel(logAnalyticsEventUseCase: logAnalyticsEventUseCase)

        return HomeTabbarController(
            homeViewController: homeViewController,
            categoryViewController: categoryViewController,
            noticeViewController: noticeViewController,
            profileViewController: profileViewController,
            viewModel: viewModel
        )
    }

    private func makeHomeView(shouldPresentBanner: Bool) -> HomeView {
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
            checkLoginUseCase: DefaultCheckLoginUseCase(userRepository: userRepository),
            sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            fetchBannerUseCase: DefaultFetchBannerUseCase(coreRepository: coreRepository),
            shouldPresentBanner: shouldPresentBanner
        )
        return HomeView(viewModel: viewModel)
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
}
