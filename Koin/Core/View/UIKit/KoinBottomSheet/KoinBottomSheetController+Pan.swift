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
              abs(velocity.y) > abs(velocity.x) else {
            return false
        }
        if let scroll = panTracking.touchedScrollView {
            if panTracking.touchedScrollWasDecelerating { return false }
            // 스크롤 영역에서 위로 끌면 항상 스크롤한다. 아래로는 스크롤이 맨 위일 때만 시트가 갖는다.
            if velocity.y < 0 { return false }
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
        guard isActive else { return }
        capturePresentationLayout()
        var height = sheetView.bounds.height
        // 키보드가 열린 채 아래로 끌면 키보드를 닫고 pan은 이어간다.
        // 하단이 키보드 높이만큼 내려가므로 시트를 그만큼 늘려 시트 상단을 손가락 아래에 둔다.
        let closesKeyboard = (velocity > 0 || translation > 0) && containsFirstResponder(contentViewController.view)
        if closesKeyboard, let host = view.superview {
            let keyboardHeight = max(0, host.safeAreaLayoutGuide.layoutFrame.maxY - host.keyboardLayoutGuide.layoutFrame.minY)
            // 기본 높이 시트는 콘텐츠를 하단에서 띄워 같이 내려가지 않게 한다. fullscreen은 콘텐츠가 늘어난 높이를 채운다.
            if !isFullScreen {
                contentBottomConstraint?.update(inset: height - contentViewController.view.frame.maxY + keyboardHeight)
            }
            height += keyboardHeight
        }
        panState = PanState(
            height: height,
            offset: containerView.transform.ty,
            translation: translation,
            baseHeight: resolvedHeight,
            startedFullScreen: isFullScreen,
            canExpand: canExpandByPan
        )
        // 키보드 알림이 pan을 끊고 높이를 되돌리지 않도록 panState와 높이를 먼저 둔다.
        didExpandForKeyboard = false
        holdHeight(height)
        if closesKeyboard {
            contentViewController.view.endEditing(true)
        }
    }

    func changePan(translation: CGFloat) {
        guard let state = panState, isActive else {
            return
        }
        let movement = state.offset + translation - state.translation
        holdHeight(state.height)
        if movement >= 0 {
            // fullscreen에서 시작하면 detent 높이까지는 시트 높이를 줄인다. 하단 고정 뷰는 그대로 두고 스크롤 영역만 줄어든다.
            // detent 아래부터는 시트 전체를 내린다.
            let free = state.startedFullScreen ? max(0, state.height - min(state.baseHeight, availableHeight)) : 0
            // 움직이던 시트를 다시 잡은 경우, 잡기 전의 이동(offset)은 줄이기에 쓰지 않아 하단이 튀지 않게 한다.
            let shrink = min(max(0, movement - state.offset), free)
            holdHeight(state.height - shrink)
            let rest = movement - shrink
            let distance = configuration.behavior.dismissOnDrag ? rest : rubberBand(rest, dimension: state.height)
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
        // fullscreen이 될 수 없는 시트는 dim을 바꾸지 않는다. 키보드 보정으로 늘어난 높이를 펼침으로 보지 않는다.
        if state.startedFullScreen || state.canExpand {
            applyNonModalDim(
                forHeight: heightConstraint?.constant ?? state.height,
                baseHeight: min(state.baseHeight, availableHeight)
            )
        }
        view.layoutIfNeeded()
    }

    func endPan(
        velocity: CGFloat,
        cancelled: Bool = false
    ) {
        guard let state = panState, isActive else {
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
