//
//  ViewRouter.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/25.
//  Copyright © 2019 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ViewRouter: ObservableObject {
    let customActionteminidex: Int
    let homeActionteminidex: Int
    var currentView: String = "home"

    let objectWillChange = PassthroughSubject<ViewRouter, Never>()

    var itemSelected: Int {
        didSet {
            if itemSelected == customActionteminidex {
                itemSelected = oldValue
                isCustomItemSelected = true
            } else if itemSelected == homeActionteminidex {
                isHomeItemSelected = true
                currentView = "home"
            }
            objectWillChange.send(self)
        }
    }
    
    func dismiss_menu() {
        isCustomItemSelected = false
        objectWillChange.send(self)
    }

    func go_home() {
        itemSelected = 1
    }

    var isHomeItemSelected: Bool = false

    /// This is true when the user has selected the Item with the custom action
    var isCustomItemSelected: Bool = false

    init(initialIndex: Int = 1, customItemIndex: Int) {
        self.customActionteminidex = customItemIndex
        self.itemSelected = initialIndex
        self.homeActionteminidex = 1
    }
}
