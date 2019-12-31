//
//  DiningViewRouter.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/31.
//  Copyright © 2019 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class DiningViewRouter: ObservableObject {
    @Published var currentView = "breakfast"
}
