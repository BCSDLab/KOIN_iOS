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

//Dining에서 선택된 탭을 담당
class DiningViewRouter: ObservableObject {
    @Published var currentView = "breakfast"  //breakfast, lunch, dinner에 따라 표시되는 탭이 달라짐
}
