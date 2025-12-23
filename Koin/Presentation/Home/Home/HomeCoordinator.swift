//
//  HomeCoordinator.swift
//  koin
//
//  Created by 김성민 on 12/20/25.
//

import Foundation
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
    
    func navigateToShop(categoryId: Int) {
        let shopCoordinator = ShopCoordinator(
            navigationController: navigationController,
            factory: DIContainer.shared
            )
        shopCoordinator.parentCoordinator = self
        addChild(shopCoordinator)
        
        shopCoordinator.navigateToShop(categoryId: categoryId)
    }
    
    func navigateToServiceSelect() {
        let serviceSelectViewController = factory.makeServiceSelectViewController()
        navigationController.pushViewController(serviceSelectViewController, animated: true)
    }
    
    func navigateToSetting() {
        let settingViewController = factory.makeSettingsViewController()
        navigationController.pushViewController(settingViewController, animated: true)
    }
    
    func presentForceUpdate() {
        let forceUpdateViewController = factory.makeForceUpdateViewController()
        navigationController.present(forceUpdateViewController, animated: true, completion: nil)
    }
    
    func showUpdateModal(onOpenStoreButtonTapped: @escaping () -> Void, onCancelButtonTapped: @escaping () -> Void) {
        let updateViewController = factory.makeUpdateModelViewController(
            onOpenStoreButtonTapped: onOpenStoreButtonTapped,
            onCancelButtonTapped: onCancelButtonTapped
        )
        navigationController.present(updateViewController, animated: true, completion: nil)
    }
}
