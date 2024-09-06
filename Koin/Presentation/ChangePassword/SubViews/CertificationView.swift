//
//  CertificationView.swift
//  koin
//
//  Created by 김나훈 on 9/6/24.
//

import Combine
import UIKit

final class CertificationView: UIView {
    
    let passwordEmptyCheckPublisher = PassthroughSubject<Bool, Never>()
    
    private let idTitleLabel = UILabel().then {
        $0.text = "아이디"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    private let idTextField = UITextField().then { textField in
        textField.isUserInteractionEnabled = false
    }
    
    private let passwordTitleLabel = UILabel().then {
        $0.text = "현재 비밀번호"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    let passwordTextField = UITextField().then { textField in
        textField.placeholder = "현재 비밀번호를 입력해주세요."
        textField.isSecureTextEntry = true
    }
    
    private let changeSecureButton = UIButton().then { button in
        button.setImage(UIImage.appImage(asset: .visibility), for: .normal)
    }
    
    private let errorResponseLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.sub500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        changeSecureButton.addTarget(self, action: #selector(changeSecureButtonTapped), for: .touchUpInside)
        passwordTextField.addTarget(self, action: #selector(passwordDidChanged), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func fillEmailText(text: String) {
        idTextField.text = text
    }
    
    func getPasswordText() -> String {
        passwordTextField.text ?? ""
    }
    
    func showErrorMessage(message: String) {
        passwordTextField.layer.borderColor = UIColor.appColor(.sub500).cgColor
        passwordTextField.layer.borderWidth = 1.0
        errorResponseLabel.text = "⚠ \(message)"
    }
}

extension CertificationView {
    @objc private func changeSecureButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
    }
    @objc private func passwordDidChanged(_ textField: UITextField) {
        passwordEmptyCheckPublisher.send(textField.text?.isEmpty ?? true)
        passwordTextField.layer.borderWidth = 0
        errorResponseLabel.text = ""
    }
}

extension CertificationView {
    private func setUpLayOuts() {
        [idTitleLabel, idTextField, passwordTitleLabel, passwordTextField, errorResponseLabel, changeSecureButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        idTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.equalTo(self.snp.leading).offset(8)
        }
        idTextField.snp.makeConstraints { make in
            make.top.equalTo(idTitleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(46)
        }
        passwordTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom).offset(30)
            make.leading.equalTo(self.snp.leading).offset(8)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTitleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(46)
        }
        errorResponseLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(5)
            make.leading.equalTo(passwordTextField.snp.leading).offset(10)
        }
        changeSecureButton.snp.makeConstraints { make in
            make.centerY.equalTo(passwordTextField.snp.centerY)
            make.trailing.equalTo(passwordTextField.snp.trailing).offset(-13)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }
    
    private func setUpTextFields() {
        [idTextField, passwordTextField].forEach {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 4
            $0.layer.masksToBounds = true
            
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
            $0.leftView = paddingView
            $0.leftViewMode = .always
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpTextFields()
        self.backgroundColor = .systemBackground
    }
    
}



