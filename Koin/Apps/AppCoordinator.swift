//
//  AppCoordinator.swift
//  koin
//
//  Created by 김성민 on 12/20/25.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator? = nil
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            factory: DIContainer.shared
        )
        
        addChild(homeCoordinator)
        homeCoordinator.parentCoordinator = self
        homeCoordinator.start()
    }
}
