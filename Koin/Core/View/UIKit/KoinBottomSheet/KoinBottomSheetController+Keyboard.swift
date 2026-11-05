//
//  KoinBottomSheetController+Keyboard.swift
//  koin
//
//  Created by 홍기정 on 10/28/26.
//

import UIKit
import Then

// MARK: - KeyboardState
extension KoinBottomSheetController {
    struct KeyboardState {
        var slideFinished = false
        var waitingForHide = false
        var timeout: DispatchWorkItem?
        let keyboardBackdropView: UIView

        @MainActor
        init() {
            keyboardBackdropView = UIView().then {
                $0.isUserInteractionEnabled = false
                $0.isHidden = true
            }
        }
    }
}

// MARK: - Internal
extension KoinBottomSheetController {
    func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    func stopObservingKeyboard() {
        keyboardState.timeout?.cancel()
        keyboardState.timeout = nil
        NotificationCenter.default.removeObserver(self)
    }

    func prepareKeyboardDismissal(for contentView: UIView) {
        keyboardState.slideFinished = false
        keyboardState.waitingForHide = containsFirstResponder(contentView)
            && !keyboardState.keyboardBackdropView.isHidden
        // endEditing이 willHide를 먼저 보내므로, 그 뒤에 슬라이드 타이밍을 고른다.
        contentView.endEditing(true)
        if keyboardState.waitingForHide {
            let timeout = DispatchWorkItem { [weak self] in
                guard let self else { return }
                keyboardState.waitingForHide = false
                finishDismissalIfReady()
            }
            keyboardState.timeout = timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: timeout)
        }
    }

    func finishKeyboardDismissalSlide() {
        keyboardState.slideFinished = true
        finishDismissalIfReady()
    }

    func containsFirstResponder(_ root: UIView) -> Bool {
        root.isFirstResponder || root.subviews.contains { containsFirstResponder($0) }
    }
}

// MARK: - Private
private extension KoinBottomSheetController {
    @objc func keyboardWillShow(_ notification: Notification) {
        keyboardState.keyboardBackdropView.isHidden = false
        if isActive,
           configuration.behavior.expandToFullScreenOnKeyboard,
           containsFirstResponder(contentViewController.view),
           !isFullScreen {
            prepareKeyboardDrivenFullScreen(true)
            didExpandForKeyboard = true
        }
        animateKeyboardLayout(notification)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if isActive, didExpandForKeyboard {
            didExpandForKeyboard = false
            prepareKeyboardDrivenFullScreen(false)
        }
        animateKeyboardLayout(notification)
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        animateKeyboardLayout(notification)
    }

    @objc func keyboardDidHide() {
        keyboardState.keyboardBackdropView.isHidden = true
        keyboardState.waitingForHide = false
        finishDismissalIfReady()
    }

    func animateKeyboardLayout(_ notification: Notification) {
        if isActive, panState == nil {
            applyTargetHeight()
        }
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [
                UIView.AnimationOptions(rawValue: curve << 16),
                .beginFromCurrentState
            ]
        ) { [weak self] in
            if let self, self.isActive, self.panState == nil {
                self.containerView.transform = .identity
            }
            self?.applyDimTarget()
            self?.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.finishPresentationIfNeeded()
        }
    }

    func finishDismissalIfReady() {
        guard isDismissing,
              keyboardState.slideFinished,
              !keyboardState.waitingForHide else {
            return
        }
        teardown()
    }
}
