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
    
    var board_id: Int
    
    var community_id: Int
    
    let currentViewChange = PassthroughSubject<String, Never>()
    
    let customItemSelectedChange = PassthroughSubject<Bool, Never>()
    
    let loadingChange = PassthroughSubject<Bool, Never>()
    
    func openLoading() {
        loadingChange.send(true)
    }
    
    func closeLoading() {
        loadingChange.send(false)
    }
    
    // 현재 뷰
    var currentView: String {
        // 값이 설정되었을 때
        didSet {
            // 오브젝트가 바뀌었다고 알려준다.
            currentViewChange.send(currentView)
            objectWillChange.send(self)
        }
    }

    // 오브젝트가 바뀌는 것을 인식해주는 오브젝트
    let objectWillChange = PassthroughSubject<ViewRouter, Never>()
    
    func open_menu() {
        isCustomItemSelected = true
        // 오브젝트가 바뀌었다고 알려준다.
        customItemSelectedChange.send(true)
    }

    // 사이드메뉴를 닫는 기능
    func dismiss_menu() {
        // 커스텀 아이템 선택을 해제한다.(사이드메뉴가 닫힌다.)
        isCustomItemSelected = false
        // 오브젝트가 바뀌었다고 알려준다.
        customItemSelectedChange.send(false)
    }


    // 홈 아이템이 선택되었는지 여부를 저장하는 값
    @Published var isHomeItemSelected: Bool = false

    // 커스텀 액션 아이템이 선택되었는지 여부를 저장하는 값
    var isCustomItemSelected: Bool = false

    init(initialIndex: Int = 1, customItemIndex: Int) {
        self.customActionteminidex = customItemIndex
        //self.itemSelected = initialIndex
        self.homeActionteminidex = 1
        self.currentView = "home"
        self.board_id = -1
        self.community_id = -1
    }
}
