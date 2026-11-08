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
    /// 시트 위쪽 그림자. dim이 없는 nonModal에서 시트 경계를 보이게 할 때 쓴다.
    var showsShadow = false
    /// 닫힘 애니메이션이 시작될 때 호출된다. 드래그로 닫는 경우도 포함한다.
    var onWillDismiss: (() -> Void)?
    /// 시트가 멈출 최종 frame(window 좌표)이 정해질 때 호출된다. 애니메이션 중간 위치는 알리지 않는다.
    var onTargetFrameChange: ((CGRect) -> Void)?
    var onDismiss: (() -> Void)?
}
