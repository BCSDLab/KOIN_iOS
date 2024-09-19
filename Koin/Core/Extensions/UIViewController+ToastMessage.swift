//
//  UIViewController+ToastMessage.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import UIKit

extension UIViewController {
    func showToast(message: String, success: Bool, showLoginButton: Bool = false) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        let backgroundColor = success
        ? UIColor.appColor(.primary900).withAlphaComponent(0.8)
        : UIColor.appColor(.danger700).withAlphaComponent(0.8)
        
        let toastLabel = PaddingLabel(frame: CGRect(x: 16, y: window.frame.height - 81, width: window.frame.width - 32, height: 54))
        toastLabel.font = UIFont.appFont(.pretendardRegular, size: 14)
        toastLabel.textAlignment = .left
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5
        toastLabel.clipsToBounds = true
        toastLabel.backgroundColor = backgroundColor
        toastLabel.textColor = UIColor.appColor(.neutral0)
        
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("로그인 하기", for: .normal)
        loginButton.setTitleColor(UIColor.appColor(.sub500), for: .normal)
        loginButton.backgroundColor = .clear
        loginButton.frame = CGRect(x: toastLabel.frame.width - 65, y: window.frame.height - 81, width: 65, height: 54)
        loginButton.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        
        window.addSubview(toastLabel)
        if showLoginButton {
            window.addSubview(loginButton)
        }
        
        let animator = UIViewPropertyAnimator(duration: 5.0, curve: .easeOut) {
            toastLabel.alpha = 0.1
            loginButton.alpha = 0.1
        }
        
        animator.addCompletion { _ in
            toastLabel.removeFromSuperview()
            loginButton.removeFromSuperview()
        }
        animator.startAnimation()
        
    }
    
    @objc private func didTapLoginButton(_ sender: UIButton) {
        sender.removeFromSuperview()
        let loginViewController = LoginViewController(viewModel: LoginViewModel(
            loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        ))
        loginViewController.title = "로그인"
        navigationController?.pushViewController(loginViewController, animated: true)
    }
}

// TODO: 이거 공통으로 사용가능한 컴포넌트로 만들기. left를 init으로 받기
final class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}
