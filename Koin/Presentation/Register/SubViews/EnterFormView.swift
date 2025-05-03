//
//  EnterFormView.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit
import Combine

final class EnterFormView: UIView {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    private let inputSubject: PassthroughSubject<RegisterFormViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
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
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "5~13자리로 입력해 주세요.", textColor: .appColor(.neutral400), font: .appFont(.pretendardRegular, size: 14))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
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
    
    private let checkIdResponseLabel: UILabel = UILabel().then {
        $0.setImageText(
            image: UIImage.appImage(asset: .checkGreenCircle),
            text: "사용 가능한 아이디 입니다.",
            font: UIFont.appFont(.pretendardRegular, size: 12),
            textColor: .appColor(.success700)
        )
        $0.isHidden = true
    }
    
    private let passwordLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "사용하실 비밀번호를 입력해 주세요."
    }
    
    private let passwordTextField1 = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "특수문자 포함 영어와 숫자 6~18자리로 입력해주세요.", textColor: .appColor(.neutral400), font: .appFont(.pretendardRegular, size: 13))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.isSecureTextEntry = true
        $0.addTarget(self, action: #selector(passwordTextField1DidChange(_:)), for: .editingChanged)
    }
    
    private let changeSecureButton1 = UIButton().then { button in
        button.setImage(UIImage.appImage(asset: .visibility), for: .normal)
        button.addTarget(self, action: #selector(changeSecureButtonTapped1), for: .touchUpInside)
    }
    
    private let seperateView2 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    private let passwordTextField2 = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "비밀번호를 다시 입력해 주세요.", textColor: .appColor(.neutral400), font: .appFont(.pretendardRegular, size: 13))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.isSecureTextEntry = true
        $0.isHidden = true
        $0.addTarget(self, action: #selector(passwordTextField2DidChange(_:)), for: .editingChanged)
    }
    
    private let changeSecureButton2 = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .visibility), for: .normal)
        $0.addTarget(self, action: #selector(changeSecureButtonTapped2), for: .touchUpInside)
        $0.isHidden = true
    }

    private let seperateView3 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
        $0.isHidden = true
    }
    
    private let correctPasswordLabel = UILabel().then {
        $0.setImageText(
            image: UIImage.appImage(asset: .checkGreenCircle),
            text: "비밀번호가 일치합니다.",
            font: UIFont.appFont(.pretendardRegular, size: 12),
            textColor: .appColor(.success700)
        )
        $0.isHidden = true
    }
    
    // MARK: Init
     init(viewModel: RegisterFormViewModel) {
         self.viewModel = viewModel
         super.init(frame: .zero)
         configureView()
         bind()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case let .showHttpResult(message, labelColor):
                self?.checkIdResponseLabel.setImageText(
                    image: UIImage.appImage(asset: .warningOrange),
                        text: message,
                        font: UIFont.appFont(.pretendardRegular, size: 12),
                        textColor: .appColor(labelColor)
                    )
            case .successCheckDuplicatedId:
                self?.checkIdResponseLabel.setImageText(
                        image: UIImage.appImage(asset: .checkGreenCircle),
                        text: "사용 가능한 아이디 입니다.",
                        font: UIFont.appFont(.pretendardRegular, size: 12),
                        textColor: .appColor(.success700)
                    )
            case .changeSendVerificationButtonStatus:
                break
            case .sendVerificationCodeSuccess(response: let response):
                break
            case .correctVerificationCode:
                break
            }
        }.store(in: &subscriptions)
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
        guard let input = textField.text else { return }

        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_.-")
        let filtered = input.lowercased().filter {
            guard let scalar = $0.unicodeScalars.first else { return false }
            return allowedCharacterSet.contains(scalar)
        }

        let trimmed = String(filtered.prefix(13))
        textField.text = trimmed

        let isValid = textField.isValidIdFormat()

        checkIdDuplicateButton.updateState(
            isEnabled: isValid,
            enabledColor: .appColor(.primary500),
            disabledColor: .appColor(.neutral300)
        )
    }
    
    @objc private func passwordTextField1DidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let isValid = textField.isValidPasswordFormat()
        [passwordTextField2, changeSecureButton2, seperateView3].forEach { $0.isHidden = !isValid }
    }
    
    @objc private func passwordTextField2DidChange(_ textField: UITextField) {
        guard let firstText = passwordTextField1.text, let secondText = passwordTextField2.text else { return }
        
        if firstText == secondText {
            correctPasswordLabel.isHidden = false
        }
    }
    
    @objc private func checkDuplicateButtonTapped() {
        guard let loginId = idTextField.text else { return }
        checkIdResponseLabel.isHidden = false
        inputSubject.send(.checkDuplicatedId(loginId))
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
        [idLabel, idTextField, seperateView1, checkIdDuplicateButton, checkIdResponseLabel, passwordLabel, passwordTextField1, changeSecureButton1, seperateView2, passwordTextField2, changeSecureButton2, seperateView3, correctPasswordLabel].forEach {
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
        
        checkIdResponseLabel.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(8)
            $0.leading.equalTo(seperateView3.snp.leading).offset(4)
            $0.height.equalTo(16)
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
            $0.trailing.equalTo(changeSecureButton1.snp.trailing)
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
            $0.trailing.equalTo(changeSecureButton2.snp.trailing)
            $0.height.equalTo(1)
        }
        
        correctPasswordLabel.snp.makeConstraints {
            $0.top.equalTo(seperateView3.snp.bottom)
            $0.leading.equalTo(seperateView3.snp.leading).offset(4)
            $0.height.equalTo(16)
        }
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
