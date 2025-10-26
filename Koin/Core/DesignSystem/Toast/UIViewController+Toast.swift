//
//  UIViewController+Toast.swift
//  koin
//
//  Created by 이은지 on 10/19/25.
//

import UIKit
import SnapKit

extension UIViewController {
    
    private var keyWindow: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window
    }

    func showToastMessage(config: ToastConfig, duration: TimeInterval = 3.0, buttonAction: (() -> Void)? = nil) {
        guard let window = keyWindow else {
            return
        }
        
        removeExistingToast(from: window)
        
        var toastMessageView: ToastMessageView!
        toastMessageView = ToastMessageView(config: config) { [weak self] in
            self?.dismissToast(toastMessageView)
            buttonAction?()
        }
        
        window.addSubview(toastMessageView)
        
        toastMessageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(window.safeAreaLayoutGuide).inset(70)
        }
        
        showToastWithAnimation(toastMessageView, duration: duration)
    }
    
    private func showToastWithAnimation(_ toastMessageView: ToastMessageView, duration: TimeInterval) {
        toastMessageView.alpha = 0
        toastMessageView.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            toastMessageView.alpha = 1
            toastMessageView.transform = .identity
        } completion: { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak toastMessageView] in
                guard let toastMessageView = toastMessageView else { return }
                self?.dismissToast(toastMessageView)
            }
        }
    }
    
    private func dismissToast(_ toastView: ToastMessageView) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn, .beginFromCurrentState]) {
            toastView.alpha = 0
            toastView.transform = CGAffineTransform(translationX: 0, y: 20)
        } completion: { _ in
            toastView.removeFromSuperview()
        }
    }
    
    private func removeExistingToast(from window: UIWindow) {
        window.subviews
            .compactMap { $0 as? ToastMessageView }
            .forEach { toastView in
                toastView.layer.removeAllAnimations()
                toastView.removeFromSuperview()
            }
    }
}

// MARK: - Convenience Methods

extension UIViewController {
    
    // 기본 Toast를 표시
    func showToastMessage(message: String, intent: ToastIntent = .neutral, duration: TimeInterval = 3.0) {
        let config = ToastConfig(
            intent: intent,
            variant: .standard,
            message: message
        )
        showToastMessage(config: config, duration: duration)
    }
    
    // 버튼이 있는 Toast를 표시
    func showToastMessage(message: String, intent: ToastIntent = .neutral, buttonTitle: String, duration: TimeInterval = 3.0, buttonAction: @escaping () -> Void) {
        let config = ToastConfig(
            intent: intent,
            variant: .action(title: buttonTitle),
            message: message
        )
        showToastMessage(config: config, duration: duration, buttonAction: buttonAction)
    }
}
