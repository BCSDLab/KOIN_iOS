//
//  UIViewController+Navigate.swift
//  koin
//
//  Created by 김나훈 on 2/14/25.
//

import UIKit

extension UIViewController {
    func navigateToLogin() {
        let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        loginViewController.title = "로그인"
        navigationController?.pushViewController(loginViewController, animated: true)
    }
}
