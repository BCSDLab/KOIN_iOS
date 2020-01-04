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
    @Published var currentView = 0
}
