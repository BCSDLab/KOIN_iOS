//
//  LostItemContainer.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import Foundation

protocol LostItemFactory {
    func makeRepostItemViewController()
    func makePostLostItemViewController()
}

extension DIContainer: LostItemFactory {
    func makeRepostItemViewController() {}
    func makePostLostItemViewController() {}
}
