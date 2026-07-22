//
//  UIViewController+Navigate.swift
//  koin
//
//  Created by 김나훈 on 2/14/25.
//

import UIKit

extension UIViewController {
    func navigateToLogin() {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let analyticsRepository = GA4AnalyticsRepository(service: GA4AnalyticsService())
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let loginUseCase = DefaultLoginUseCase(userRepository: userRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: analyticsRepository)
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: userRepository)
        let sendDeviceTokenIfNeededUseCase = DefaultSendDeviceTokenIfNeededUseCase(
            userRepository: userRepository,
            notiRepository: notiRepository
        )
        let viewModel = LoginViewModel(
            loginUseCase: loginUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            fetchUserDataUseCase: fetchUserDataUseCase,
            sendDeviceTokenIfNeededUseCase: sendDeviceTokenIfNeededUseCase
        )
        let loginViewController = LoginViewController(viewModel: viewModel)
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    func replaceTopViewController(_ viewController: UIViewController, animated: Bool) {
        if var viewControllers = navigationController?.viewControllers {
            let _ = viewControllers.removeLast()
            viewControllers.append(viewController)
            navigationController?.setViewControllers(viewControllers, animated: animated)
        }
    }
}
