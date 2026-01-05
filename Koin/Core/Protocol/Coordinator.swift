//
//  Coordinator.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

extension Coordinator {
    func addChild(_ child: Coordinator) {
        childCoordinators.append(child)
    }
    
    func removeChild(_ child: Coordinator?) {
        guard let child = child else { return }
        childCoordinators = childCoordinators.filter { $0 !== child }
    }
}
