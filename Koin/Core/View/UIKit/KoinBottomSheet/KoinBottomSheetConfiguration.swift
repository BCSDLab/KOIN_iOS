//
//  KoinBottomSheetConfiguration.swift
//  koin
//
//  Created by 홍기정 on 10/28/26.
//

import UIKit

/// 콘텐츠가 정한 높이로 표시하며, 공간이 부족하면 하단 기준으로 위가 잘린다.
struct KoinBottomSheetConfiguration {
    enum Style {
        case modal(dimAlpha: CGFloat = 0.7)
        case nonModal
    }

    struct Behavior {
        var dismissOnDrag = true
        var expandToFullScreenOnDrag = false
        var expandToFullScreenOnKeyboard = false
    }

    var style: Style = .modal()
    var behavior: Behavior = .init()
    var cornerRadius: CGFloat = 32
    var onDismiss: (() -> Void)?
}
