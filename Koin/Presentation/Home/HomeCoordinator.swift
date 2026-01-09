//
//  HomeCoordinator.swift
//  koin
//
//  Created by 김성민 on 12/20/25.
//

import UIKit

final class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    private let factory: HomeFactory
        
    init(navigationController: UINavigationController, factory: HomeFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() {
        let homeViewController = factory.makeHomeViewController()
        homeViewController.coordinator = self
        navigationController.setViewControllers([homeViewController], animated: false)
    }
    
    func pushShopViewController(categoryId: Int) {
        let shopCoordinator = ShopCoordinator(
            navigationController: navigationController,
            factory: DIContainer.shared
        )
        shopCoordinator.parentCoordinator = self
        addChild(shopCoordinator)
        
        shopCoordinator.pushShopViewController(categoryId: categoryId)
    }
    
    func pushServiceSelectViewController() {
        let serviceSelectViewController = factory.makeServiceSelectViewController()
        serviceSelectViewController.coordinator = self
        navigationController.pushViewController(serviceSelectViewController, animated: true)
    }
        
    func presentForceUpdate() {
        let forceUpdateViewController = factory.makeForceUpdateViewController()
        forceUpdateViewController.coordinator = self
        navigationController.present(forceUpdateViewController, animated: true, completion: nil)
    }
    
    func presentUpdateViewController(onOpenStoreButtonTapped: @escaping () -> Void, onCancelButtonTapped: @escaping () -> Void) {
        let updateViewController = factory.makeUpdateModelViewController(
            onOpenStoreButtonTapped: onOpenStoreButtonTapped,
            onCancelButtonTapped: onCancelButtonTapped
        )
        navigationController.present(updateViewController, animated: true, completion: nil)
    }
    
    func presentBannerViewControllerA(
        viewModel: HomeViewModel,
        banners: [Banner],
        defaultHeight: CGFloat = 389,
        cornerRadius: CGFloat = 16,
        dimmedAlpha: CGFloat = 0.4,
        isPannedable: Bool = false,
        modalPresentationStyle: UIModalPresentationStyle = .overFullScreen,
        modalTransitionStyle: UIModalTransitionStyle = .crossDissolve,
        onBannerTapped: @escaping (Banner)->Void
    ) {
        let bannerViewControllerA = factory.makeBannerViewControllerA(
            viewModel: viewModel,
            onBannerTapped: onBannerTapped
        )
        bannerViewControllerA.setBanners(banners: banners)
        presentBottomSheetViewController(
            contentViewController: bannerViewControllerA,
            defaultHeight: defaultHeight,
            cornerRadius: cornerRadius,
            dimmedAlpha: dimmedAlpha,
            isPannedable: isPannedable,
            modalPresentationStyle: modalPresentationStyle,
            modalTransitionStyle: modalTransitionStyle
        )
    }
}
