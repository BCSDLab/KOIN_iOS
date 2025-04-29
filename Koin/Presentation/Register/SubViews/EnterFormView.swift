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
    
    // MARK: - UI Components
    private let idLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "사용하실 아이디를 입력해 주세요."
    }
    
    private let seperateView1 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }

    private let idTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(string: "최대 13자리까지 입력 가능합니다.", attributes: [.foregroundColor: UIColor.appColor(.neutral400), .font: UIFont.appFont(.pretendardRegular, size: 14)])
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.autocapitalizationType = .none
        $0.addTarget(self, action: #selector(idTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    private let checkIdDuplicateButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral300)
        $0.setTitle("중복 확인", for: .normal)
        $0.setTitleColor(.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 10)
        $0.layer.cornerRadius = 4
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(checkDuplicateButtonTapped), for: .touchUpInside)
    }
    
    private let passwordLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "사용하실 비밀번호를 입력해 주세요."
    }
    
    // 6~8자
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
    
    private let correctImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .checkGreenCircle)
        $0.isHidden = true
    }
    
    private let correctLabel: UILabel = UILabel().then {
        $0.text = "비밀번호가 일치합니다."
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.success700)
        $0.isHidden = true
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
    
    // FIXME: - 학생 완료하면 외부인 해야함
    func configure(for userType: SelectTypeFormView.UserType?) {
        switch userType {
        case .student:
            idLabel.textColor = .black
        case .general:
            idLabel.textColor = .blue
        case .none:
            break
        }
    }
}

extension EnterFormView {
    @objc private func idTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_.-")
        
        let filteredText = text.lowercased().filter {
            guard let scalar = $0.unicodeScalars.first else { return false }
            return allowedCharacterSet.contains(scalar)
        }
        
        let trimmedText = String(filteredText.prefix(13))
        textField.text = trimmedText
        
        let isValid = textField.isValidIDFormat()
        
        // 버튼 상태 확장 메서드
        checkIdDuplicateButton.updateState(
            isEnabled: isValid,
            enabledColor: .appColor(.primary500),
            disabledColor: .appColor(.neutral300)
        )
    }
    
    @objc private func checkDuplicateButtonTapped() {
//        inputSubject.send(.sendVerificationCode(phoneNumber))
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

// MARK: UI Settings
extension EnterFormView {
    private func setUpLayOuts() {
        [idLabel, idTextField, seperateView1, checkIdDuplicateButton, passwordLabel, passwordTextField1, changeSecureButton1, seperateView2, passwordTextField2, changeSecureButton2, seperateView3, correctImageView, correctLabel].forEach {
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
            $0.trailing.equalTo(checkIdDuplicateButton.snp.leading).offset(-16)
            $0.height.equalTo(40)
        }
        
        seperateView1.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom)
            $0.leading.equalTo(idLabel.snp.leading)
            $0.trailing.equalTo(idTextField.snp.trailing)
            $0.height.equalTo(1)
        }
        
        checkIdDuplicateButton.snp.makeConstraints {
            $0.centerY.equalTo(idTextField.snp.centerY)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(32)
            $0.width.lessThanOrEqualTo(86)
        }
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(29)
        }
        
        passwordTextField1.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(12)
            $0.leading.equalTo(passwordLabel.snp.leading).offset(4)
            $0.trailing.equalTo(checkIdDuplicateButton.snp.trailing)
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
            $0.trailing.equalTo(checkIdDuplicateButton.snp.trailing)
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
        
        correctImageView.snp.makeConstraints {
            $0.top.equalTo(seperateView3.snp.bottom).offset(10)
            $0.leading.equalTo(seperateView3.snp.leading).offset(4)
            $0.width.height.equalTo(16)
        }
        
        correctLabel.snp.makeConstraints {
            $0.centerY.equalTo(correctImageView.snp.centerY)
            $0.leading.equalTo(correctImageView.snp.trailing).offset(8)
        }
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
