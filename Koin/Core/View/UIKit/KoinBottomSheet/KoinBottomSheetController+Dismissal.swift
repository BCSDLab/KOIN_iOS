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
        guard isActive, let context = heightContext else { return }
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
        let oldHost = parent
        state = .dismissed
        cancelPanForAction()
        animator?.stopAnimation(true)
        animator = nil
        stopObservingKeyboard()
        navigationObservation = nil
        contentViewController.willMove(toParent: nil)
        contentViewController.view.removeFromSuperview()
        contentViewController.removeFromParent()
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        updateNavigationGesture(host: oldHost)
        let onDismiss = configuration.onDismiss
        let action = pendingAction
        configuration.onDismiss = nil
        pendingAction = nil
        onDismiss?()
        action?()
    }

    func updateNavigationGesture(host: UIViewController? = nil) {
        guard isModal, let host = host ?? parent else { return }
        let navigation = (host as? UINavigationController)
            ?? host.navigationController
            ?? ((host as? UITabBarController)?.selectedViewController as? UINavigationController)
        let hasModal = host.children
            .compactMap { $0 as? KoinBottomSheetController }
            .contains { $0.isModal && $0.state != .dismissed }
        navigation?.interactivePopGestureRecognizer?.isEnabled = !hasModal
            && (navigation?.viewControllers.count ?? 0) > 1
        if state != .dismissed, navigationObservation == nil {
            navigationObservation = navigation?.interactivePopGestureRecognizer?.observe(
                \.isEnabled, options: [.new]) { [weak self] gesture, _ in
                MainActor.assumeIsolated {
                    guard let self, self.state != .dismissed, gesture.isEnabled else { return }
                    // CustomNavigationController가 push/pop 뒤 이 값을 다시 계산할 수 있다.
                    // 그 delegate는 바꾸지 않고, 마지막 teardown까지 modal 잠금을 유지한다.
                    gesture.isEnabled = false
                }
            }
        }
    }

    @objc func dimTapped() {
        guard isActive else { return }
        dismiss()
        parent?.view.endEditing(true)
    }
}
