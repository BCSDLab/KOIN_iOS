//
//  KoinBottomSheetController+Dismissal.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

extension KoinBottomSheetController: KoinBottomSheetDelegate {
    func dismiss(completion: (() -> Void)?) {
        guard isActive else { return }
        pendingAction = completion
        beginDismissal(isReplacement: false)
    }

    func invalidateHeight(animated: Bool) {
        guard isActive else { return }
        guard let context = heightContext else {
            lastContext = nil
            return
        }
        // capture와 resolver가 레이아웃을 불러도 같은 맥락을 중복 측정하지 않는다.
        lastContext = context
        cancelPanForAction()
        capturePresentationLayout()
        resolveHeight(in: context)
        // fullscreen도 기존 target 복구 경로를 탄다. 키보드 자동 펼침 상태는 보존한다.
        animateToTarget(animated: animated)
    }

    func setFullScreen(_ fullScreen: Bool, animated: Bool) {
        guard isActive else { return }
        cancelPanForAction()
        capturePresentationLayout()
        didExpandForKeyboard = false
        isFullScreen = fullScreen
        animateToTarget(animated: animated)
    }
}

extension KoinBottomSheetController {
    func beginDismissal(isReplacement: Bool, velocity: CGFloat = 0) {
        guard isActive else { return }
        cancelPanForAction()
        capturePresentationLayout()
        holdHeight(sheetView.bounds.height)
        state = .dismissing
        let onWillDismiss = configuration.onWillDismiss
        configuration.onWillDismiss = nil
        onWillDismiss?()
        prepareKeyboardDismissal(for: contentViewController.view)
        let distance = view.bounds.maxY - containerView.frame.minY
        let targetY = containerView.transform.ty + distance
        runSpring(
            animated: true,
            velocity: velocity,
            distance: distance,
            dismissing: true
        ) { [weak self] in
            guard let self else { return }
            self.dimView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: targetY)
        } completion: { [weak self] in
            self?.finishKeyboardDismissalSlide()
        }
    }

    func teardown() {
        guard state != .dismissed else { return }
        state = .dismissed
        cancelPanForAction()
        animator?.stopAnimation(true)
        animator = nil
        stopObservingKeyboard()
        ownerWindowObserver?.removeFromSuperview()
        ownerWindowObserver = nil
        contentViewController.willMove(toParent: nil)
        contentViewController.view.removeFromSuperview()
        contentViewController.removeFromParent()
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        let onDismiss = configuration.onDismiss
        let action = pendingAction
        configuration.onDismiss = nil
        pendingAction = nil
        onDismiss?()
        action?()
    }

    @objc func dimTapped() {
        guard isActive else { return }
        dismiss()
        parent?.view.endEditing(true)
    }
}
