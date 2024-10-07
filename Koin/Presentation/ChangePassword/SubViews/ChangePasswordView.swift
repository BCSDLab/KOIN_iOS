//
//  ChangePasswordView.swift
//  koin
//
//  Created by 김나훈 on 9/6/24.
//

import Combine
import UIKit

final class ChangePasswordView: UIView {
    
    let passwordEmptyCheckPublisher = PassthroughSubject<Bool, Never>()
    private let viewModel: ChangePasswordViewModel
    
    private let passwordLabel = UILabel().then {
        $0.text = "새 비밀번호"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    let passwordTextField = UITextField().then { textField in
        textField.placeholder = "새 비밀번호를 입력해주세요."
        textField.isSecureTextEntry = true
    }
    
    private let englishStackView = UIStackView().then { stackView in
    }
    
    private let numberStackView = UIStackView().then { stackView in
    }
    
    private let letterStackView = UIStackView().then { stackView in
    }
    
    private let countStackView = UIStackView().then { stackView in
    }
    
    private let passwordCheckLabel = UILabel().then {
        $0.text = "새 비밀번호 확인"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    let passwordCheckTextField = UITextField().then { textField in
        textField.placeholder = "새 비밀번호를 다시 입력해주세요."
        textField.layer.borderColor = UIColor.appColor(.sub500).cgColor
        textField.isSecureTextEntry = true
    }
    
    private let changeSecureButton1 = UIButton().then { button in
        button.setImage(UIImage.appImage(asset: .visibility), for: .normal)
    }
    
    private let changeSecureButton2 = UIButton().then { button in
        button.setImage(UIImage.appImage(asset: .visibility), for: .normal)
    }
    
    private let errorResponseLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.sub500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
    }
    
    // MARK: Init
    
    init(frame: CGRect, viewModel: ChangePasswordViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        configureView()
        changeSecureButton1.addTarget(self, action: #selector(changeSecureButtonTapped), for: .touchUpInside)
        changeSecureButton2.addTarget(self, action: #selector(changeSecureButtonTapped), for: .touchUpInside)
        passwordTextField.addTarget(self, action: #selector(passwordDidChanged), for: .editingChanged)
        passwordCheckTextField.addTarget(self, action: #selector(passwordDidChanged), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChangePasswordView {
    
    func getPasswordText() -> String {
        passwordTextField.text ?? ""
    }
    
    @objc private func changeSecureButtonTapped(_ button: UIButton) {
        switch button {
        case changeSecureButton1: 
            passwordTextField.isSecureTextEntry.toggle()
            changeSecureButton1.setImage(passwordTextField.isSecureTextEntry ? UIImage.appImage(asset: .visibility) : UIImage.appImage(asset: .visibilityNon), for: .normal)
        default: passwordCheckTextField.isSecureTextEntry.toggle()
            changeSecureButton2.setImage(passwordCheckTextField.isSecureTextEntry ? UIImage.appImage(asset: .visibility) : UIImage.appImage(asset: .visibilityNon), for: .normal)
        }
        
    }
    @objc private func passwordDidChanged(_ textField: UITextField) {
        let isMatch = passwordCheckTextField.text == passwordTextField.text
        viewModel.isCompleted.1 = isMatch
        
        if textField == passwordTextField {
            let text = textField.text ?? ""
            let result = PasswordValidator().validate(password: text)
            let resultArray = [result.0, result.1, result.2, result.3]
            [englishStackView, numberStackView, letterStackView, countStackView].enumerated().forEach { (index, stackView) in
                updateStackView(isPassed: resultArray[index], stackView: stackView)
            }
            viewModel.isCompleted.0 = resultArray.allSatisfy({$0 == false})
           
        } else {
            passwordCheckTextField.layer.borderWidth = isMatch ? 0.0 : 1.0
            errorResponseLabel.text = isMatch ? "" : "⚠ 비밀번호가 일치하지 않습니다."
        }
        
        
    }
    
    private func updateStackView(isPassed: Bool, stackView: UIStackView) {
        let image = isPassed ? UIImage.appImage(asset: .check) : UIImage.appImage(asset: .checkGreen)
        let textColor = isPassed ? UIColor.appColor(.neutral500) : UIColor.appColor(.success700)
        for subview in stackView.arrangedSubviews {
            if let imageView = subview as? UIImageView, let newImage = image {
                imageView.image = newImage
            }
            if let label = subview as? UILabel {
                label.textColor = textColor
            }
        }
    }
}

extension ChangePasswordView {
    private func setUpLayOuts() {
        [passwordLabel, passwordTextField, englishStackView, numberStackView, letterStackView, countStackView, passwordCheckLabel, passwordCheckTextField, changeSecureButton1, changeSecureButton2, errorResponseLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.equalTo(self.snp.leading).offset(8)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(46)
        }
        englishStackView.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(8)
            make.leading.equalTo(self.snp.leading)
            make.height.equalTo(22)
            make.width.equalTo(170)
        }
        numberStackView.snp.makeConstraints { make in
            make.top.equalTo(englishStackView.snp.bottom)
            make.leading.equalTo(self.snp.leading)
            make.height.equalTo(22)
            make.width.equalTo(170)
        }
        letterStackView.snp.makeConstraints { make in
            make.top.equalTo(numberStackView.snp.bottom)
            make.leading.equalTo(self.snp.leading)
            make.height.equalTo(22)
            make.width.equalTo(170)
        }
        countStackView.snp.makeConstraints { make in
            make.top.equalTo(letterStackView.snp.bottom)
            make.leading.equalTo(self.snp.leading)
            make.height.equalTo(22)
            make.width.equalTo(170)
        }
        passwordCheckLabel.snp.makeConstraints { make in
            make.top.equalTo(countStackView.snp.bottom).offset(12)
            make.leading.equalTo(self.snp.leading).offset(8)
        }
        passwordCheckTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordCheckLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(46)
        }
        errorResponseLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordCheckTextField.snp.bottom).offset(5)
            make.leading.equalTo(passwordCheckTextField.snp.leading).offset(10)
        }
        changeSecureButton1.snp.makeConstraints { make in
            make.centerY.equalTo(passwordTextField.snp.centerY)
            make.trailing.equalTo(passwordTextField.snp.trailing).offset(-13)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        changeSecureButton2.snp.makeConstraints { make in
            make.centerY.equalTo(passwordCheckTextField.snp.centerY)
            make.trailing.equalTo(passwordCheckTextField.snp.trailing).offset(-13)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }
    
    private func setUpTextFields() {
        [passwordTextField, passwordCheckTextField].forEach {
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
    
    private func setUpStackView(stackView: UIStackView, text: String) {
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        configureStackView(with: stackView, text: text)
    }
    func configureStackView(with stackView: UIStackView, text: String) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let imageView = UIImageView(image: UIImage.appImage(asset: .check))
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.heightAnchor.constraint(equalToConstant: 22)
        ])
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpTextFields()
        let texts = ["영어 포함", "숫자 포함", "특수문자 포함", "6자에서 18자 이내"]
        [englishStackView, numberStackView, letterStackView, countStackView].enumerated().forEach { (index, stackView) in
            setUpStackView(stackView: stackView, text: texts[index])
        }
        self.backgroundColor = .systemBackground
    }
    
}



