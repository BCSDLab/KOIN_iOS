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
        /// owner 화면의 child로 붙어 화면과 함께 움직인다. 사용자 동작으로 닫히지 않고, dim이 없으며, swipe pop을 막지 않는다.
        /// owner의 viewDidLoad에서 띄우면 애니메이션 없이 처음부터 보인다.
        /// configuration 클로저와 콘텐츠 뷰의 클로저는 owner를 [weak self]로 잡아야 owner와 함께 해제된다.
        case persistent
    }

    struct Behavior {
        var isDraggable = true
        var dismissOnDrag = true
        var expandToFullScreenOnDrag = false
        var expandToFullScreenOnKeyboard = false
    }

    var style: Style = .modal()
    var behavior: Behavior = .init()
    var cornerRadius: CGFloat = 32
    /// 닫힘 애니메이션이 시작될 때 호출된다. 드래그로 닫는 경우도 포함한다.
    var onWillDismiss: (() -> Void)?
    /// 시트가 멈출 최종 frame(window 좌표)이 정해질 때 호출된다. 애니메이션 중간 위치는 알리지 않는다.
    var onTargetFrameChange: ((CGRect) -> Void)?
    var onDismiss: (() -> Void)?
}
