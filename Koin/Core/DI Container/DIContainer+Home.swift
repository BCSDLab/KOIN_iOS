//
//  HomeContainer.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import Foundation

protocol HomeFactory {
    func makeHomeViewController() -> HomeViewController
    func makeServiceSelectViewController() -> ServiceSelectViewController
    func makeForceUpdateViewController() -> ForceUpdateViewController
    func makeUpdateModelViewController(
        onOpenStoreButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: @escaping ()->Void
    ) -> UpdateModelViewController
    func makeBannerViewControllerA(
        viewModel: HomeViewModel,
        onBannerTapped: @escaping (Banner)->Void
    ) -> BannerViewControllerA
}

extension DIContainer: HomeFactory {
    func makeHomeViewController() -> HomeViewController {
        let diningRepository = DefaultDiningRepository(
            diningService: DefaultDiningService(),
            shareService: KakaoShareService())
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let logAnalyticsEventUseCase = resolve(type: LogAnalyticsEventUseCase.self)
        let getUserScreenTimeUseCase = resolve(type: GetUserScreenTimeUseCase.self)
        let fetchShopCategoryUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let dateProvider = DefaultDateProvider()
        let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: DefaultNoticeListRepository(service: DefaultNoticeService()))
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let checkVersionUseCase = DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))
        let assignAbTestUseCase = resolve(type: AssignAbTestUseCase.self)
        let fetchKeywordNoticePhraseUseCase = DefaultFetchKeywordNoticePhraseUseCase()
        let homeViewModel = HomeViewModel(
            fetchDiningListUseCase: fetchDiningListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryUseCase,
            dateProvider: dateProvider,
            checkVersionUseCase: checkVersionUseCase,
            assignAbTestUseCase: assignAbTestUseCase,
            fetchKeywordNoticePhraseUseCase: fetchKeywordNoticePhraseUseCase,
            checkLoginUseCase: checkLoginUseCase
        )
        let viewController = HomeViewController(viewModel: homeViewModel)
        return viewController
    }
    
    func makeServiceSelectViewController() -> ServiceSelectViewController {
        let logAnalyticsEventUseCase = resolve(type: LogAnalyticsEventUseCase.self)
        let viewModel = ServiceSelectViewModel(
            fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())),
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        return ServiceSelectViewController(viewModel: viewModel)
    }
    
    func makeForceUpdateViewController() -> ForceUpdateViewController {
        let logAnalyticsEventUseCase = resolve(type: LogAnalyticsEventUseCase.self)
        let viewModel = ForceUpdateViewModel(
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            checkVersionUseCase: DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService())))
        let viewController = ForceUpdateViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }
    
    func makeUpdateModelViewController(
        onOpenStoreButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: @escaping ()->Void
    ) -> UpdateModelViewController {
        let viewController = UpdateModelViewController(
            onOpenStoreButtonTapped: onOpenStoreButtonTapped,
            onCancelButtonTapped: onCancelButtonTapped
        )
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        return viewController
    }
    
    func makeBannerViewControllerA(
        viewModel: HomeViewModel,
        onBannerTapped: @escaping (Banner)->Void
    ) -> BannerViewControllerA {
        let bannerViewControllerA = BannerViewControllerA(
            viewModel: viewModel,
            onBannerTapped: onBannerTapped
        )
        return bannerViewControllerA
    }
}
