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
    private let contentTopLayoutGuide = UILayoutGuide()
    private let contentLayoutGuide = UILayoutGuide()
    private let contentBottomLayoutGuide = UILayoutGuide()

    private let logoImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .bcsdSymbolLogo)
        $0.contentMode = .scaleAspectFit
    }

    private let logoTextImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .koinTextLogo)
        $0.contentMode = .scaleAspectFit
    }
    
    private let registerCompletionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "회원가입이 완료되었습니다."
    }
    
    private let loginButton = UIButton().then {
        $0.setTitle("로그인 바로가기", for: .normal)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .appColor(.new500)
        $0.setTitleColor(UIColor(.white), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let homeButton = UIButton().then {
        $0.setTitle("홈화면 바로가기", for: .normal)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .appColor(.neutral0)
        $0.setTitleColor(.appColor(.new500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.layer.borderColor = UIColor.appColor(.new500).cgColor
        $0.layer.borderWidth = 1
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
            if let loginVC = navigationController.viewControllers.first(where: { $0 is LoginViewController }) {
                navigationController.popToViewController(loginVC, animated: true)
            }
        }
    }

    @objc private func homeButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension RegisterCompletionViewController {
    private func setUpLayout() {
        [logoImageView, logoTextImageView, registerCompletionLabel, loginButton, homeButton].forEach {
            view.addSubview($0)
        }

        [contentTopLayoutGuide, contentLayoutGuide, contentBottomLayoutGuide].forEach {
            view.addLayoutGuide($0)
        }
    }
    
    private func setUpConstraints() {
        logoImageView.snp.makeConstraints {
            $0.top.centerX.equalTo(contentLayoutGuide)
            $0.height.equalTo(66)
        }

        logoTextImageView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(9)
            $0.centerX.equalTo(contentLayoutGuide)
            $0.width.equalTo(102)
            $0.height.equalTo(41)
        }

        registerCompletionLabel.snp.makeConstraints {
            $0.top.equalTo(logoTextImageView.snp.bottom).offset(24)
            $0.bottom.equalTo(loginButton.snp.top).offset(-56)
            $0.centerX.equalTo(contentLayoutGuide)
            $0.height.equalTo(29)
        }
        
        loginButton.snp.makeConstraints {
            $0.horizontalEdges.equalTo(contentLayoutGuide).inset(48)
            $0.height.equalTo(48)
        }
        
        homeButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(24)
            $0.horizontalEdges.equalTo(contentLayoutGuide).inset(48)
            $0.bottom.equalTo(contentLayoutGuide)
            $0.height.equalTo(48)
        }

        contentTopLayoutGuide.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(contentLayoutGuide.snp.top)
            $0.height.equalTo(contentBottomLayoutGuide.snp.height).multipliedBy(2.0/3.0)
        }

        contentLayoutGuide.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(contentBottomLayoutGuide.snp.top)
        }

        contentBottomLayoutGuide.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureView() {
        setUpLayout()
        setUpConstraints()
        self.view.backgroundColor = .white
    }
}
