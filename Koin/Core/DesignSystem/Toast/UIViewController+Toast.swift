//
//  UIViewController+Toast.swift
//  koin
//
//  Created by 이은지 on 10/19/25.
//

import UIKit
import SnapKit

extension UIViewController {
    
    // ✅ 추가: Window 찾기 로직을 computed property로 분리
    private var keyWindow: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window
    }
    
    /// Toast 메시지를 표시합니다.
    /// - Parameters:
    ///   - config: Toast 설정 (intent, variant, message)
    ///   - duration: Toast가 표시될 시간 (기본값: 3초)
    ///   - buttonAction: 버튼 탭 시 실행될 클로저
    func showToastMessage(
        config: ToastConfig,
        duration: TimeInterval = 3.0,
        buttonAction: (() -> Void)? = nil
    ) {
        guard let window = keyWindow else {
            return
        }
        
        // 기존 Toast 제거 (중복 방지)
        removeExistingToast(from: window)
        
        // ✅ 수정: 먼저 ToastMessageView 선언
        var toastMessageView: ToastMessageView!
        toastMessageView = ToastMessageView(config: config) { [weak self] in
            self?.dismissToast(toastMessageView)
            buttonAction?()
        }
        
        window.addSubview(toastMessageView)
        
        // 제약조건 설정
        toastMessageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(window.safeAreaLayoutGuide).inset(16)
        }
        
        // 애니메이션으로 표시
        showToastWithAnimation(toastMessageView, duration: duration)
    }
    
    /// Toast를 애니메이션과 함께 표시합니다.
    private func showToastWithAnimation(_ toastMessageView: ToastMessageView, duration: TimeInterval) {
        toastMessageView.alpha = 0
        toastMessageView.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            toastMessageView.alpha = 1
            toastMessageView.transform = .identity
        } completion: { [weak self] _ in
            // duration 후 자동으로 제거
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak toastMessageView] in
                guard let toastMessageView = toastMessageView else { return }
                self?.dismissToast(toastMessageView)
            }
        }
    }
    
    /// Toast를 즉시 제거합니다.
    private func dismissToast(_ toastView: ToastMessageView) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseIn, .beginFromCurrentState]
        ) {
            toastView.alpha = 0
            toastView.transform = CGAffineTransform(translationX: 0, y: 20)
        } completion: { _ in
            toastView.removeFromSuperview()
        }
    }
    
    /// 기존 Toast를 제거합니다.
    private func removeExistingToast(from window: UIWindow) {
        window.subviews
            .compactMap { $0 as? ToastMessageView }
            .forEach { toastView in
                // ✅ 추가: 애니메이션 중단 후 제거
                toastView.layer.removeAllAnimations()
                toastView.removeFromSuperview()
            }
    }
}

// MARK: - Convenience Methods

extension UIViewController {
    
    /// 기본 Toast를 표시합니다. (텍스트만)
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - intent: Toast 의도 (기본값: .neutral)
    ///   - duration: 표시 시간 (기본값: 3초)
    func showToastMessage(
        message: String,
        intent: ToastIntent = .neutral,
        duration: TimeInterval = 3.0
    ) {
        let config = ToastConfig(
            intent: intent,
            variant: .standard,
            message: message
        )
        showToastMessage(config: config, duration: duration)
    }
    
    /// 버튼이 있는 Toast를 표시합니다.
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - intent: Toast 의도 (기본값: .neutral)
    ///   - buttonTitle: 버튼 타이틀
    ///   - duration: 표시 시간 (기본값: 3초)
    ///   - buttonAction: 버튼 탭 시 실행될 클로저
    func showToastMessage(
        message: String,
        intent: ToastIntent = .neutral,
        buttonTitle: String,
        duration: TimeInterval = 3.0,
        buttonAction: @escaping () -> Void
    ) {
        let config = ToastConfig(
            intent: intent,
            variant: .action(title: buttonTitle),
            message: message
        )
        showToastMessage(config: config, duration: duration, buttonAction: buttonAction)
    }
    
    /// 여러 줄 Toast를 표시합니다.
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - intent: Toast 의도 (기본값: .neutral)
    ///   - maxLines: 최대 줄 수
    ///   - duration: 표시 시간 (기본값: 3초)
    func showToastMessage(
        message: String,
        intent: ToastIntent = .neutral,
        maxLines: Int,
        duration: TimeInterval = 3.0
    ) {
        let config = ToastConfig(
            intent: intent,
            variant: .overflow(lines: maxLines),
            message: message
        )
        showToastMessage(config: config, duration: duration)
    }
}

// MARK: - Quick Access Methods

extension UIViewController {
    
    /// 성공 Toast를 표시합니다.
    func showSuccessToast(message: String) {
        showToastMessage(message: message, intent: .positive)
    }
    
    /// 에러 Toast를 표시합니다.
    func showErrorToast(message: String) {
        showToastMessage(message: message, intent: .negative)
    }
    
    /// 정보 Toast를 표시합니다.
    func showInfoToast(message: String) {
        showToastMessage(message: message, intent: .informative)
    }
}
