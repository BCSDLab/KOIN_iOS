//
//  HomeContainer.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import UIKit

protocol HomeFactory {
    func makeHomeViewController()
    func makeServiceSelectViewController()
    func makeForceUpdateViewController()
}

extension DIContainer: HomeFactory {
    func makeHomeViewController() {}
    func makeServiceSelectViewController() {}
    func makeForceUpdateViewController() {}
}
