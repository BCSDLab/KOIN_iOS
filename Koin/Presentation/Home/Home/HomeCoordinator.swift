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
}
