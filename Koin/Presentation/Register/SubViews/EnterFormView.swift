//
//  EnterFormView.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit

final class EnterFormView: UIView {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    
    // MARK: - UI Components 16
    private let idLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "아이디 (전화번호)"
    }
    
    private let seperateView1 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    private let idTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(string: "아이디", attributes: [.foregroundColor: UIColor.appColor(.neutral400), .font: UIFont.appFont(.pretendardRegular, size: 14)])
        $0.autocapitalizationType = .none
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    private let passwordLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "사용하실 비밀번호를 입력해 주세요."
    }
    
    private let passwordTextField1 = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(string: "특수문자 포함 영어와 숫자 6~18자리로 입력해주세요.", attributes: [.foregroundColor: UIColor.appColor(.neutral400), .font: UIFont.appFont(.pretendardRegular, size: 13)])
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.autocapitalizationType = .none
        $0.isSecureTextEntry = true
    }
    
    private let changeSecureButton1 = UIButton().then { button in
        button.setImage(UIImage.appImage(asset: .visibility), for: .normal)
        button.addTarget(self, action: #selector(changeSecureButtonTapped1), for: .touchUpInside)
    }
    
    private let seperateView2 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    private let passwordTextField2 = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(string: "비밀번호를 다시 입력해 주세요.", attributes: [.foregroundColor: UIColor.appColor(.neutral400), .font: UIFont.appFont(.pretendardRegular, size: 13)])
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.autocapitalizationType = .none
        $0.isSecureTextEntry = true
    }
    
    private let changeSecureButton2 = UIButton().then { button in
        button.setImage(UIImage.appImage(asset: .visibility), for: .normal)
        button.addTarget(self, action: #selector(changeSecureButtonTapped2), for: .touchUpInside)
    }
    
    private let seperateView3 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    // MARK: Init
     init(viewModel: RegisterFormViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func changeSecureButtonTapped1() {
        passwordTextField1.isSecureTextEntry.toggle()
        changeSecureButton1.setImage(passwordTextField1.isSecureTextEntry ? UIImage.appImage(asset: .visibility) : UIImage.appImage(asset: .visibilityNon), for: .normal)
    }
    
    @objc private func changeSecureButtonTapped2() {
        passwordTextField2.isSecureTextEntry.toggle()
        changeSecureButton2.setImage(passwordTextField2.isSecureTextEntry ? UIImage.appImage(asset: .visibility) : UIImage.appImage(asset: .visibilityNon), for: .normal)
    }
}

extension EnterFormView {
   
}

// MARK: UI Settings

extension EnterFormView {
    private func setUpLayOuts() {
        [idLabel, idTextField, seperateView1, passwordLabel, passwordTextField1, changeSecureButton1, seperateView2, passwordTextField2, changeSecureButton2, seperateView3].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        idLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(29)
        }
        
        idTextField.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(12)
            $0.leading.equalTo(idLabel.snp.leading).offset(4)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(40)
        }
        
        seperateView1.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom)
            $0.leading.equalTo(idLabel.snp.leading)
            $0.trailing.equalTo(idTextField.snp.trailing)
            $0.height.equalTo(1)
        }
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(29)
        }
        
        passwordTextField1.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(12)
            $0.leading.equalTo(passwordLabel.snp.leading).offset(4)
            $0.trailing.equalToSuperview().offset(-40)
            $0.height.equalTo(40)
        }
        
        changeSecureButton1.snp.makeConstraints {
            $0.centerY.equalTo(passwordTextField1.snp.centerY)
            $0.trailing.equalToSuperview().offset(-8)
            $0.width.height.equalTo(20)
        }
        
        seperateView2.snp.makeConstraints {
            $0.top.equalTo(passwordTextField1.snp.bottom)
            $0.leading.equalTo(passwordLabel.snp.leading)
            $0.trailing.equalTo(idTextField.snp.trailing)
            $0.height.equalTo(1)
        }
        
        passwordTextField2.snp.makeConstraints {
            $0.top.equalTo(seperateView2.snp.bottom).offset(12)
            $0.leading.equalTo(passwordLabel.snp.leading).offset(4)
            $0.trailing.equalToSuperview().offset(-40)
            $0.height.equalTo(40)
        }
        
        changeSecureButton2.snp.makeConstraints {
            $0.centerY.equalTo(passwordTextField2.snp.centerY)
            $0.trailing.equalToSuperview().offset(-8)
            $0.width.height.equalTo(20)
        }
        
        seperateView3.snp.makeConstraints {
            $0.top.equalTo(passwordTextField2.snp.bottom)
            $0.leading.equalTo(passwordLabel.snp.leading)
            $0.trailing.equalTo(idTextField.snp.trailing)
            $0.height.equalTo(1)
        }
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
