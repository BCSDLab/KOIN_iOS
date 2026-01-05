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
    func makeSettingsViewController() -> SettingsViewController
    func makeUpdateModelViewController(
        onOpenStoreButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: @escaping ()->Void
    ) -> UpdateModelViewController
}

extension DIContainer: HomeFactory {
    func makeHomeViewController() -> HomeViewController {
        let diningRepository = DefaultDiningRepository(
            diningService: DefaultDiningService(),
            shareService: KakaoShareService())
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let fetchShopCategoryUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: DefaultNoticeListRepository(service: DefaultNoticeService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let dateProvider = DefaultDateProvider()
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let checkVersionUseCase = DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))
        let assignAbTestUseCase = DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService()))
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
        let viewModel = ServiceSelectViewModel(
            fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
        return ServiceSelectViewController(viewModel: viewModel)
    }
    
    func makeForceUpdateViewController() -> ForceUpdateViewController {
        let viewModel = ForceUpdateViewModel(
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())),
            checkVersionUseCase: DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService())))
        let viewController = ForceUpdateViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }
    
    func makeSettingsViewController() -> SettingsViewController {
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = SettingsViewModel(logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        return SettingsViewController(viewModel: viewModel)
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
}
