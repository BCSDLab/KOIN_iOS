//
//  RegisterCompletionViewController.swift
//  koin
//
//  Created by 이은지 on 5/6/25.
//

import UIKit
import SnapKit

final class RegisterCompletionViewController: UIViewController {
    
    // MARK: - UI Components
    private let koinLogoImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .koinLogo)
    }
    
    private let registerCompletionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "회원가입이 완료되었습니다."
    }
    
    private let loginButton = UIButton().then {
        $0.setTitle("로그인 바로가기", for: .normal)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.appColor(.sub500)
        $0.setTitleColor(UIColor(.white), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let homeButton = UIButton().then {
        $0.setTitle("홈화면 바로가기", for: .normal)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitleColor(UIColor(.white), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTarget()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    private func setAddTarget() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
    }
}

extension RegisterCompletionViewController {
    @objc private func loginButtonTapped() {
        if let navigationController = self.navigationController {
            let viewControllers = navigationController.viewControllers
            let targetIndex = max(0, viewControllers.count - 3)
            navigationController.popToViewController(viewControllers[targetIndex], animated: true)
        }
    }
    
    @objc private func homeButtonTapped() {
        if let navigationController = self.navigationController {
            let viewControllers = navigationController.viewControllers
            let targetIndex = max(0, viewControllers.count - 5)
            navigationController.popToViewController(viewControllers[targetIndex], animated: true)
        }
    }
}

extension RegisterCompletionViewController {
    private func setUpLayOuts() {
        [koinLogoImageView, registerCompletionLabel, loginButton, homeButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        koinLogoImageView.snp.makeConstraints {
            $0.bottom.equalTo(registerCompletionLabel.snp.top).offset(-24)
            $0.centerX.equalToSuperview()
            $0.height.greaterThanOrEqualTo(56)
            $0.width.greaterThanOrEqualTo(96)
        }

        registerCompletionLabel.snp.makeConstraints {
            $0.bottom.equalTo(loginButton.snp.top).offset(-56)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(29)
        }
        
        loginButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
        
        homeButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

