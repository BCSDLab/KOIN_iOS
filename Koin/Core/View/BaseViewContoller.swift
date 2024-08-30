//
//  BaseViewContoller.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import UIKit
import FirebaseAnalytics
// 오른쪽 위에 네비게이션 버튼이 있는 ViewController.
// 다른 ViewController는 BaseViewController를 상속받음
class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        let commonButton = UIBarButtonItem(image: UIImage.appImage(symbol: .line3horizontal), style: .plain, target: self, action: #selector(commonButtonTapped))
        self.navigationItem.rightBarButtonItem = commonButton
    }
    
    @objc func commonButtonTapped() {
        let serviceSelectViewController = ServiceSelectViewController(viewModel: ServiceSelectViewModel(fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), sendDeviceTokenUseCase: DefaultSendDeviceTokenUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))))
        navigationController?.pushViewController(serviceSelectViewController, animated: true)
    }
}
