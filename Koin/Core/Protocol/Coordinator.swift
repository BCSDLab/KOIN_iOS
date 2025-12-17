//
//  Coordinator.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var children: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
}
