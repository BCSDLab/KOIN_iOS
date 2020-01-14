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
    // 커스텀 액션(사이트메뉴 열기)이 위치해있는 탭 번호
    let customActionteminidex: Int
    // 홈 액션이 위치해있는 탭 번호
    let homeActionteminidex: Int
    // 현재 뷰
    var currentView: String = "home"

    // 오브젝트가 바뀌는 것을 인식해주는 오브젝트
    let objectWillChange = PassthroughSubject<ViewRouter, Never>()

    // 선택된 아이템을 저장하는 값
    var itemSelected: Int {
        // 값이 설정되었을 때
        didSet {
            // 만약 설정된 값이 커스텀 액션이 일어나는 값이랑 같을 때
            if itemSelected == customActionteminidex {
                // 전에 위치해있던 값으로 바꾼 후에
                itemSelected = oldValue
                // 커스텀 아이템이 눌렸다고 알려준다.(사이드메뉴가 열린다.)
                isCustomItemSelected = true
                // 만약 설정된 값이 홈 액션이 일어나는 값이랑 같을 때
            } else if itemSelected == homeActionteminidex {
                // 홈 아이템이 눌렸다고 알려주고
                isHomeItemSelected = true
                // 현재 위치를 home으로 변경해준다.
                currentView = "home"
            }
            // 오브젝트가 바뀌었다고 알려준다.
            objectWillChange.send(self)
        }
    }

    // 사이드메뉴를 닫는 기능
    func dismiss_menu() {
        // 커스텀 아이템 선택을 해제한다.(사이드메뉴가 닫힌다.)
        isCustomItemSelected = false
        // 오브젝트가 바뀌었다고 알려준다.
        objectWillChange.send(self)
    }

    // 홈으로 돌아가는 기능
    func go_home() {
        // 선택된 탭을 홈으로 바꿔준다.
        itemSelected = 1
    }

    // 홈 아이템이 선택되었는지 여부를 저장하는 값
    var isHomeItemSelected: Bool = false

    // 커스텀 액션 아이템이 선택되었는지 여부를 저장하는 값
    var isCustomItemSelected: Bool = false

    init(initialIndex: Int = 1, customItemIndex: Int) {
        self.customActionteminidex = customItemIndex
        self.itemSelected = initialIndex
        self.homeActionteminidex = 1
    }
}
