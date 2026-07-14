//
//  ProfileHostingController.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI
import UIKit

final class ProfileHostingController: UIHostingController<ProfileView>, HostingControllerProtocol {
    
    // MARK: - Initializer
    override init(rootView: ProfileView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
    }    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func execute(action: ProfileView.Action) {
        switch action {
        case .showLogin:
            navigationController?.pushViewController(makeLoginViewController(), animated: true)
        case .showLogout:
            showLogOutAlert()
        case .showSetting:
            navigationController?.pushViewController(makeSettingsViewController(), animated: true)
        case .showTimeTable:
            navigationController?.pushViewController(makeTimeTableViewController(), animated: true)
        }
    }
}

extension ProfileHostingController {
    private func showLogOutAlert() {
        let alertTitle = "로그아웃"
        let alertMessage = "로그아웃 하시겠습니까?"
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.rootView.logout()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func makeLoginViewController() -> UIViewController {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let viewModel = LoginViewModel(
            loginUseCase: DefaultLoginUseCase(userRepository: userRepository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
            ),
            fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: userRepository),
            sendDeviceTokenIfNeededUseCase: DefaultSendDeviceTokenIfNeededUseCase(
                userRepository: userRepository,
                notiRepository: DefaultNotiRepository(service: DefaultNotiService())
            )
        )
        return LoginViewController(viewModel: viewModel)
    }
    
    private func makeTimeTableViewController() -> UIViewController {
        return TimetableViewController(viewModel: TimetableViewModel())
    }
    
    private func makeSettingsViewController() -> UIViewController {
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        return SettingsViewController(viewModel: SettingsViewModel(logAnalyticsEventUseCase: logAnalyticsEventUseCase))
    }
}
