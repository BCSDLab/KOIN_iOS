//
//  ChildCoordinator.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import UIKit

@MainActor
protocol ChildCoordinator: AnyObject {
    associatedtype Route
    var parentCoordinator: RootCoordinator? { get set }
    var rootViewController: UIViewController? { get set }
    var navigationController: CustomNavigationController { get set }
    init(parentCoordinator: RootCoordinator, navigationController: CustomNavigationController)
    func start(route: Route)
    func makeViewController(route: Route) -> UIViewController
}

extension ChildCoordinator {
    func start(route: Route, animated: Bool = true) {
        let viewController = makeViewController(route: route)
        rootViewController = viewController
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func push(route: Route, animated: Bool = true) {
        let viewController = makeViewController(route: route)
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func present(route: Route, animated: Bool = true) {
        let viewController = makeViewController(route: route)
        navigationController.present(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }
    
    func dismissPresented(animated: Bool = true) {
        navigationController.dismiss(animated: animated)
    }
}
