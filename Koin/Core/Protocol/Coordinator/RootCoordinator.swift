//
//  RootCoordinator.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import UIKit
import PhotosUI

@MainActor
protocol RootCoordinator: AnyObject, PHPickerViewControllerDelegate {
    var children: [any ChildCoordinator] { get set }
    var navigationController: CustomNavigationController { get set }
    var pickerCompletion: ((UIImage) -> Void)? { get set }
    func start<C: ChildCoordinator>(_ type: C.Type, route: C.Route)
}

extension RootCoordinator {
    func start<C: ChildCoordinator>(_ type: C.Type, route: C.Route) {
        let child = C.init(parentCoordinator: self, navigationController: navigationController)
        children.append(child)
        child.start(route: route)
    }
}
