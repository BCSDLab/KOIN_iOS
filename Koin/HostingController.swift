//
//  HostingController.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// 상단바 스타일을 임의로 밝은 색으로 설정하기 위한 HostingController 생성
class HostingController<Content> : UIHostingController<Content> where Content : View {
    @objc override dynamic open var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
