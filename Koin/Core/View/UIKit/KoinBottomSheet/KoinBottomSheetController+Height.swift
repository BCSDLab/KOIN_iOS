//
//  KoinBottomSheetController+Height.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

extension KoinBottomSheetController {
    /// 시트가 올라갈 수 있는 상단 한계. host가 nav·tab이어도 owner 화면의 safe area(내비게이션 바 아래)에서 멈춘다.
    var topLimitGuide: UILayoutGuide? {
        guard let host = view.superview else { return nil }
        if let ownerView = owner?.viewIfLoaded, ownerView.isDescendant(of: host) {
            return ownerView.safeAreaLayoutGuide
        }
        return host.safeAreaLayoutGuide
    }

    /// host 좌표계의 상단 한계 y.
    var topLimitY: CGFloat? {
        guard let host = view.superview, let guide = topLimitGuide, let guideView = guide.owningView else { return nil }
        return guideView.convert(guide.layoutFrame, to: host).minY
    }

    var heightContext: KoinBottomSheetContext? {
        guard let host = view.superview, let topLimitY else { return nil }
        let width = view.bounds.width
        let maximumHeight = host.safeAreaLayoutGuide.layoutFrame.maxY - topLimitY
        guard view.window != nil,
              width.isFinite, width > 0,
              maximumHeight.isFinite,
              maximumHeight > 0 else {
            return nil
        }
        return KoinBottomSheetContext(
            width: width,
            maximumHeight: maximumHeight
        )
    }

    func resolveHeight(in context: KoinBottomSheetContext) {
        // sheet와 콘텐츠 내부 컬렉션의 실제 너비를 먼저 갱신한다.
        containerView.layoutIfNeeded()
        sheetView.layoutIfNeeded()
        contentViewController.view.layoutIfNeeded()
        let height = contentViewController.contentView.sheetHeight(in: context)
        resolvedHeight = height.isFinite && height > 0 ? height : context.maximumHeight
    }

    func updateHeightIfNeeded() {
        guard isActive, let context = heightContext else { return }
        if let lastContext,
           abs(lastContext.width - context.width) <= 0.5,
           abs(lastContext.maximumHeight - context.maximumHeight) <= 0.5 {
            return
        }
        // 측정 전 저장: 중첩 레이아웃은 이 맥락을 이미 처리 중인 것으로 본다.
        lastContext = context
        // capture가 끊은 spring의 dim·표시 완료는 여기서 복구한다. 첫 표시 측정은 fade를 위해 건드리지 않는다.
        let wasAnimating = animator != nil
        cancelPanForAction()
        capturePresentationLayout()
        resolveHeight(in: context)
        // fullscreen은 새 자연 높이를 캐시하되, 표시 target은 fullscreen 그대로다.
        applyTargetHeight()
        containerView.transform = .identity
        if wasAnimating {
            applyDimTarget()
        }
        view.layoutIfNeeded()
        if wasAnimating {
            finishPresentationIfNeeded()
        }
    }

    var availableHeight: CGFloat {
        guard let host = view.superview, let topLimitY else { return 0 }
        return max(0, host.keyboardLayoutGuide.layoutFrame.minY - topLimitY)
    }

    /// 화면 크기보다 큰 유한값을 선호하고, required 상한은 Auto Layout에 맡긴다.
    func applyTargetHeight() {
        guard let heightConstraint else { return }
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.constant = isFullScreen ? max(view.bounds.height * 2, 1) : resolvedHeight
        heightConstraint.isActive = true
    }

    func holdHeight(_ height: CGFloat) {
        heightConstraint?.priority = UILayoutPriority(999)
        heightConstraint?.constant = max(0, height)
    }

    func setKeyboardFullScreen(_ value: Bool) {
        isFullScreen = value
        applyTargetHeight()
    }

    /// 키보드가 진행 중인 표시·pan을 이어받아도 하단과 dim을 정상 표시 상태로 복구한다.
    func prepareKeyboardDrivenFullScreen(_ value: Bool) {
        cancelPanForAction()
        capturePresentationLayout()
        setKeyboardFullScreen(value)
    }
}
