//
//  KoinBottomSheetController+Pan.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import UIKit

extension KoinBottomSheetController: UIGestureRecognizerDelegate {
    struct PanState {
        let height: CGFloat
        let offset: CGFloat
        let translation: CGFloat
        let baseHeight: CGFloat
        let startedFullScreen: Bool
        let canExpand: Bool
    }

    struct PanTracking {
        var sheetPan: UIPanGestureRecognizer?
        var ignoresCurrentPan = false
        weak var touchedScrollView: UIScrollView?
        var touchedScrollWasDecelerating = false
    }

    /// 놓을 때 이 시간(초)만큼 현재 속도로 더 움직인 높이로 목적지를 정한다.
    private static let releaseProjectionSeconds: CGFloat = 0.2

    /// 위로 끄는 pan이 시트를 fullscreen까지 펼칠 수 있는지.
    private var canExpandByPan: Bool {
        configuration.behavior.expandToFullScreenOnDrag && !isFullScreen
            && sheetView.bounds.height < availableHeight - 0.5
    }

    func configurePan() {
        guard configuration.behavior.dismissOnDrag || configuration.behavior.expandToFullScreenOnDrag else { return }
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleSheetPan(_:))
        )
        pan.delegate = self
        sheetView.addGestureRecognizer(pan)
        panTracking.sheetPan = pan
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        guard gestureRecognizer === panTracking.sheetPan else { return true }
        // 소비한 터치의 moved/ended로는 재인식하지 않고 새 touch에서만 다시 허용한다.
        if touch.phase == .began { panTracking.ignoresCurrentPan = false }
        guard !panTracking.ignoresCurrentPan else { return false }
        panTracking.touchedScrollView = nil
        var node = touch.view
        while let current = node, current !== sheetView {
            if let scroll = current as? UIScrollView,
               scroll.contentSize.height + scroll.adjustedContentInset.top + scroll.adjustedContentInset.bottom > scroll.bounds.height || scroll.alwaysBounceVertical {
                panTracking.touchedScrollView = scroll
                break
            }
            node = current.superview
        }
        panTracking.touchedScrollWasDecelerating = panTracking.touchedScrollView?.isDecelerating ?? false
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panTracking.sheetPan,
              let pan = panTracking.sheetPan else {
            return true
        }
        let velocity = pan.velocity(in: view)
        guard isActive,
              !panTracking.ignoresCurrentPan,
              abs(velocity.y) > abs(velocity.x) else {
            return false
        }
        if let scroll = panTracking.touchedScrollView {
            if panTracking.touchedScrollWasDecelerating { return false }
            // 위로는 펼칠 수 있을 때만 시트가, 아래로는 스크롤이 맨 위일 때만 시트가 갖는다.
            if velocity.y < 0 { return canExpandByPan }
            if scroll.contentOffset.y > -scroll.adjustedContentInset.top + 0.5 {
                return false
            }
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard gestureRecognizer === panTracking.sheetPan,
              let scroll = otherGestureRecognizer.view as? UIScrollView,
              otherGestureRecognizer === scroll.panGestureRecognizer else {
            return false
        }
        return scroll.isDescendant(of: sheetView)
    }

    @objc private func handleSheetPan(_ pan: UIPanGestureRecognizer) {
        guard !panTracking.ignoresCurrentPan else { return }
        switch pan.state {
        case .began:
            beginPan(
                translation: pan.translation(in: view).y,
                velocity: pan.velocity(in: view).y
            )
        case .changed:
            changePan(translation: pan.translation(in: view).y)
        case .ended:
            endPan(velocity: pan.velocity(in: view).y)
        case .cancelled, .failed:
            endPan(
                velocity: 0,
                cancelled: true
            )
        default:
            break
        }
    }

    func beginPan(
        translation: CGFloat,
        velocity: CGFloat = 0
    ) {
        guard isActive, !panTracking.ignoresCurrentPan else { return }
        // 키보드가 열린 첫 아래 드래그는 키보드만 닫고 소비한다.
        if (velocity > 0 || translation > 0), containsFirstResponder(contentViewController.view) {
            panTracking.ignoresCurrentPan = true
            panState = nil
            capturePresentationLayout()
            applyTargetHeight()
            // transform은 기존 keyboardWillHide의 애니메이션 블록에서 identity로 복귀한다.
            contentViewController.view.endEditing(true)
            panTracking.sheetPan?.isEnabled = false
            panTracking.sheetPan?.isEnabled = true
            return
        }
        capturePresentationLayout()
        let height = sheetView.bounds.height
        panState = PanState(
            height: height,
            offset: containerView.transform.ty,
            translation: translation,
            baseHeight: resolvedHeight,
            startedFullScreen: isFullScreen,
            canExpand: canExpandByPan
        )
        didExpandForKeyboard = false
        holdHeight(height)
    }

    func changePan(translation: CGFloat) {
        guard let state = panState,
              isActive,
              !panTracking.ignoresCurrentPan else {
            return
        }
        let movement = state.offset + translation - state.translation
        holdHeight(state.height)
        if movement >= 0 {
            let free = state.startedFullScreen ? max(0, state.height - min(state.baseHeight, availableHeight)) : 0
            let distance = configuration.behavior.dismissOnDrag || movement <= free
                ? movement : free + rubberBand(movement - free, dimension: state.height)
            containerView.transform = CGAffineTransform(translationX: 0, y: distance)
        } else if state.canExpand && !state.startedFullScreen && state.height < availableHeight - 0.5 {
            let desiredHeight = state.height - movement
            holdHeight(min(desiredHeight, availableHeight))
            let overflow = max(0, desiredHeight - availableHeight)
            containerView.transform = CGAffineTransform(translationX: 0,
                y: -rubberBand(overflow, dimension: state.height))
        } else {
            // 높이를 바꾸지 않고 콘텐츠와 하단 배경 전체를 함께 위로 움직인다.
            containerView.transform = CGAffineTransform(translationX: 0,
                y: -rubberBand(-movement, dimension: state.height))
        }
        view.layoutIfNeeded()
    }

    func endPan(
        velocity: CGFloat,
        cancelled: Bool = false
    ) {
        guard let state = panState,
              isActive,
              !panTracking.ignoresCurrentPan else {
            return
        }
        let effective = sheetView.bounds.height - containerView.transform.ty
        let projected = effective - velocity * Self.releaseProjectionSeconds
        let base = min(state.baseHeight, availableHeight)
        let midpoint = (base + availableHeight) / 2
        var full = state.startedFullScreen
        var close = false
        if !cancelled {
            full = projected >= midpoint && (state.startedFullScreen || state.canExpand)
            close = !full && projected < base * 2 / 3 && configuration.behavior.dismissOnDrag
        }
        panState = nil
        if close {
            beginDismissal(
                isReplacement: false,
                velocity: velocity
            )
        } else {
            setKeyboardFullScreen(full)
            animateToTarget(
                animated: true,
                velocity: velocity
            )
        }
    }

    func cancelPanForAction() {
        guard panState != nil else { return }
        panState = nil
        panTracking.sheetPan?.isEnabled = false
        panTracking.sheetPan?.isEnabled = true
    }

    private func rubberBand(
        _ distance: CGFloat,
        dimension: CGFloat
    ) -> CGFloat {
        let size = max(1, dimension)
        return (1 - 1 / (distance * 0.55 / size + 1)) * size
    }
}
