//
//  EnterFormView.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit
import Combine
import DropDown

final class EnterFormView: UIView {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    private let inputSubject: PassthroughSubject<RegisterFormViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var userType: SelectTypeFormView.UserType?
    
    // MARK: - UI Components
    private let idLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "사용하실 아이디를 입력해 주세요."
    }

    private let idTextField = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "5~13자리로 입력해 주세요.", textColor: .appColor(.neutral400), font: .appFont(.pretendardRegular, size: 14))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
    }
    
    private let checkIdDuplicateButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral300)
        $0.setTitle("중복 확인", for: .normal)
        $0.setTitleColor(.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 10)
        $0.layer.cornerRadius = 4
        $0.isEnabled = false
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
    }
    
    private let passwordTextField2 = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "비밀번호를 다시 입력해 주세요.", textColor: .appColor(.neutral400), font: .appFont(.pretendardRegular, size: 13))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.isSecureTextEntry = true
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
    
    private let studentInfoGuideLabel = UILabel().then {
        $0.text = "학부와 학번을 알려주세요."
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.isHidden = true
    }
    
    private let departmentDropdownButton = UIButton().then {
        $0.applyDropdownStyle(
            title: "학부",
            font: UIFont.appFont(.pretendardRegular, size: 14),
            titleColor: .appColor(.neutral800),
            borderColor: .appColor(.neutral400),
            backgroundColor: .appColor(.neutral0),
            icon: UIImage.appImage(symbol: .chevronDown)
        )
        $0.layer.cornerRadius = 12
        $0.isHidden = true
    }
    
    private let deptDropDown = DropDown().then {
        $0.backgroundColor = .systemBackground
        $0.isHidden = true
    }
    
    private let studentIdTextField = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "학번을 입력해주세요.", textColor: .appColor(.neutral400), font: .appFont(.pretendardRegular, size: 13))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.isHidden = true
    }
    
    private let studentIdWarningLabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "올바른 학번 양식이 아닙니다. 다시 입력해 주세요.", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.sub500))
        $0.isHidden = true
    }
    
    private let studentNicknameTextField = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "닉네임은 변경 가능합니다. (선택)", textColor: .appColor(.neutral400), font: .appFont(.pretendardRegular, size: 13))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.isHidden = true
    }
    
    private let checkStudentNicknameDuplicateButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral300)
        $0.setTitle("중복 확인", for: .normal)
        $0.setTitleColor(.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 10)
        $0.layer.cornerRadius = 4
        $0.isEnabled = false
        $0.isHidden = true
    }
    
    private let studentNicknameWarningLabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "중복된 닉네임입니다. 다시 입력해 주세요.", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.sub500))
        $0.isHidden = true
    }
    
    private let studentEmailTextField = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "koreatech 이메일(선택)", textColor: .appColor(.neutral400), font: .appFont(.pretendardRegular, size: 13))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.isHidden = true
    }
    
    private let emailLabel = UILabel().then {
        $0.text = "koreatech.ac.kr"
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral400)
        $0.isHidden = true
    }

    // MARK: Init
    init(viewModel: RegisterFormViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureView()
        setAddTarget()
        bind()
        inputSubject.send(.getDeptList)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpTextFieldUnderline()
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
                        text: "사용 가능한 아이디입니다.",
                        font: UIFont.appFont(.pretendardRegular, size: 12),
                        textColor: .appColor(.success700)
                    )
            case .changeSendVerificationButtonStatus:
                break
            case .sendVerificationCodeSuccess(response: let response):
                break
            case .correctVerificationCode:
                break
            case let .showDeptDropDownList(deptList):
                self?.setUpDropDown(dropDown: strongSelf.deptDropDown, button: strongSelf.departmentDropdownButton, dataSource: deptList)
            case .changeCheckButtonStatus:
                self?.checkStudentNicknameDuplicateButton.updateState(
                    isEnabled: false,
                    enabledColor: .appColor(.primary500),
                    disabledColor: .appColor(.neutral300)
                )
                self?.studentNicknameWarningLabel.setImageText(image: .appImage(asset: .checkGreenCircle), text: "사용 가능한 닉네임입니다.", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.sub700))

            }
        }.store(in: &subscriptions)
    }
    
    private func setAddTarget() {
        idTextField.addTarget(self, action: #selector(idTextFieldDidChange(_:)), for: .editingChanged)
        checkIdDuplicateButton.addTarget(self, action: #selector(checkDuplicateButtonTapped), for: .touchUpInside)
        passwordTextField1.setRightToggleButton(image: .appImage(asset: .visibility), target: self, action: #selector(changeSecureButtonTapped1))
        passwordTextField1.addTarget(self, action: #selector(passwordTextField1DidChange(_:)), for: .editingChanged)
        passwordTextField2.setRightToggleButton(image: .appImage(asset: .visibility), target: self, action: #selector(changeSecureButtonTapped2))
        passwordTextField2.addTarget(self, action: #selector(passwordTextField2DidChange(_:)), for: .editingChanged)
        departmentDropdownButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        studentIdTextField.setRightButton(image: UIImage.appImage(asset: .cancelNeutral500), target: self, action: #selector(clearStudentIdTextField))
        studentIdTextField.addTarget(self, action: #selector(studentIdTextFieldDidChange(_:)), for: .editingChanged)
        studentNicknameTextField.setRightButton(image: UIImage.appImage(asset: .cancelNeutral500), target: self, action: #selector(clearStudentNicknameTextField))
        studentNicknameTextField.addTarget(self, action: #selector(nicknameTextFieldDidChange(_:)), for: .editingChanged)
        checkStudentNicknameDuplicateButton.addTarget(self, action: #selector(checkStudentNicknameDuplicateButtonTapped), for: .touchUpInside)
        studentEmailTextField.addTarget(self, action: #selector(studentEmailTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    func configure(for userType: SelectTypeFormView.UserType?) {
        self.userType = userType
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
        guard textField.text != nil else { return }
        let isValid = textField.isValidPasswordFormat()
        passwordTextField2.isHidden = !isValid
    }
    
    @objc private func passwordTextField2DidChange(_ textField: UITextField) {
        guard let firstText = passwordTextField1.text, let secondText = passwordTextField2.text else { return }

        if firstText == secondText {
            correctPasswordLabel.isHidden = false

            if userType == .student {
                [studentInfoGuideLabel, departmentDropdownButton, deptDropDown,
                 studentIdTextField, studentNicknameTextField, checkStudentNicknameDuplicateButton,
                 studentEmailTextField, emailLabel].forEach {
                    $0.isHidden = false
                }
            }
        }
    }
    
    @objc private func checkDuplicateButtonTapped() {
        guard let loginId = idTextField.text else { return }
        checkIdResponseLabel.isHidden = false
        inputSubject.send(.checkDuplicatedId(loginId))
    }
    
    @objc private func changeSecureButtonTapped1() {
        passwordTextField1.isSecureTextEntry.toggle()
        
        if let container = passwordTextField1.rightView,
           let button = container.subviews.first as? UIButton {
            let image = passwordTextField1.isSecureTextEntry
                ? UIImage.appImage(asset: .visibility)
                : UIImage.appImage(asset: .visibilityNon)
            button.setImage(image, for: .normal)
        }
    }
    
    @objc private func changeSecureButtonTapped2() {
        passwordTextField2.isSecureTextEntry.toggle()
        
        if let container = passwordTextField2.rightView,
           let button = container.subviews.first as? UIButton {
            let image = passwordTextField2.isSecureTextEntry
                ? UIImage.appImage(asset: .visibility)
                : UIImage.appImage(asset: .visibilityNon)
            button.setImage(image, for: .normal)
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        self.layoutIfNeeded()
        deptDropDown.show()
    }
    
    @objc private func clearStudentIdTextField() {
        studentIdTextField.text = nil
    }
    
    @objc private func studentIdTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        let numericText = text.filter { $0.isNumber }
        let trimmedText = String(numericText.prefix(10))
        
        textField.text = trimmedText

        let yearPart = String(trimmedText.prefix(4))
        let isYearValid: Bool = {
            guard let year = Int(yearPart) else { return false }
            let currentYear = Calendar.current.component(.year, from: Date())
            return (1991...currentYear).contains(year)
        }()

        let isLengthValid = trimmedText.count >= 8 && trimmedText.count <= 10

        studentIdWarningLabel.isHidden = isLengthValid && isYearValid
    }

    
    @objc private func clearStudentNicknameTextField() {
        studentNicknameTextField.text = nil
    }
    
    @objc private func nicknameTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        let trimmedText = String(text.prefix(10))
        textField.text = trimmedText

        let isValid = !trimmedText.isEmpty && trimmedText.count <= 10
        checkStudentNicknameDuplicateButton.updateState(
            isEnabled: isValid,
            enabledColor: .appColor(.primary500),
            disabledColor: .appColor(.neutral300)
        )
    }
    
    @objc private func checkStudentNicknameDuplicateButtonTapped() {
        guard let nicknameText = studentNicknameTextField.text else { return }
        inputSubject.send(.checkDuplicatedNickname(nicknameText))
        studentNicknameWarningLabel.isHidden = false
    }
    
    @objc private func studentEmailTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789._-")
        
        let filteredText = text.filter { String($0).rangeOfCharacter(from: allowedCharacterSet) != nil }

        let trimmedText = String(filteredText.prefix(30))
        textField.text = trimmedText
    }
}

// MARK: UI Settings
extension EnterFormView {
    private func setUpLayOuts() {
        [idLabel, idTextField, checkIdDuplicateButton, checkIdResponseLabel,
         passwordLabel, passwordTextField1, passwordTextField2,
         correctPasswordLabel, studentInfoGuideLabel,
         departmentDropdownButton, deptDropDown, studentIdTextField,
         studentIdWarningLabel, studentNicknameTextField, checkStudentNicknameDuplicateButton,
         studentNicknameWarningLabel,
         studentEmailTextField, emailLabel
        ].forEach {
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
        
        checkIdDuplicateButton.snp.makeConstraints {
            $0.centerY.equalTo(idTextField.snp.centerY)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(32)
            $0.width.lessThanOrEqualTo(86)
        }
        
        checkIdResponseLabel.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(8)
            $0.leading.equalTo(idTextField.snp.leading).offset(4)
            $0.height.equalTo(20)
        }
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(29)
        }
        
        passwordTextField1.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(12)
            $0.leading.equalTo(passwordLabel.snp.leading).offset(4)
            $0.trailing.equalTo(checkIdDuplicateButton.snp.trailing)
            $0.height.equalTo(40)
        }
        
        passwordTextField2.snp.makeConstraints {
            $0.top.equalTo(passwordTextField1.snp.bottom).offset(12)
            $0.leading.equalTo(passwordLabel.snp.leading).offset(4)
            $0.trailing.equalTo(checkIdDuplicateButton.snp.trailing)
            $0.height.equalTo(40)
        }
        
        correctPasswordLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField2.snp.bottom)
            $0.leading.equalTo(passwordTextField2.snp.leading).offset(4)
            $0.height.equalTo(20)
        }
        
        studentInfoGuideLabel.snp.makeConstraints {
            $0.top.equalTo(correctPasswordLabel.snp.bottom).offset(32)
            $0.leading.equalTo(passwordLabel.snp.leading)
            $0.height.equalTo(29)
        }
        
        departmentDropdownButton.snp.makeConstraints {
            $0.top.equalTo(studentInfoGuideLabel.snp.bottom).offset(8)
            $0.leading.equalTo(passwordTextField1.snp.leading)
            $0.trailing.equalTo(passwordTextField1.snp.trailing)
            $0.height.equalTo(40)
        }
        
        studentIdTextField.snp.makeConstraints {
            $0.top.equalTo(departmentDropdownButton.snp.bottom).offset(8)
            $0.leading.equalTo(departmentDropdownButton.snp.leading)
            $0.trailing.equalTo(departmentDropdownButton.snp.trailing)
            $0.height.equalTo(40)
        }
        
        studentIdWarningLabel.snp.makeConstraints {
            $0.top.equalTo(studentIdTextField.snp.bottom)
            $0.leading.equalTo(studentIdTextField.snp.leading)
            $0.height.equalTo(20)
        }
        
        studentNicknameTextField.snp.makeConstraints {
            $0.top.equalTo(studentIdTextField.snp.bottom).offset(8)
            $0.leading.equalTo(departmentDropdownButton.snp.leading)
            $0.trailing.equalTo(checkStudentNicknameDuplicateButton.snp.leading).offset(-16)
            $0.height.equalTo(40)
        }
        
        checkStudentNicknameDuplicateButton.snp.makeConstraints {
            $0.centerY.equalTo(studentNicknameTextField.snp.centerY)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(32)
            $0.width.lessThanOrEqualTo(86)
        }
        
        studentNicknameWarningLabel.snp.makeConstraints {
            $0.top.equalTo(studentNicknameTextField.snp.bottom)
            $0.leading.equalTo(studentNicknameTextField.snp.leading)
            $0.height.equalTo(20)
        }
        
        studentEmailTextField.snp.makeConstraints {
            $0.top.equalTo(studentNicknameTextField.snp.bottom).offset(8)
            $0.leading.equalTo(departmentDropdownButton.snp.leading)
            $0.trailing.equalToSuperview().offset(-126)
            $0.height.equalTo(40)
        }
        
        emailLabel.snp.makeConstraints {
            $0.centerY.equalTo(studentEmailTextField.snp.centerY)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(22)
        }
    }
    
    private func setUpTextFieldUnderline() {
        [idTextField, studentIdTextField, studentNicknameTextField,
         passwordTextField1, passwordTextField2, studentEmailTextField].forEach {
            $0.setUnderline(color: .appColor(.neutral300), thickness: 1, leftPadding: 0, rightPadding: 0)
        }
    }
    
    private func setUpDropDown(dropDown: DropDown, button: UIButton, dataSource: [String]) {
        dropDown.anchorView = button
        dropDown.bottomOffset = CGPoint(x: 0, y: button.bounds.height)
        dropDown.dataSource = dataSource
        dropDown.direction = .bottom
        dropDown.selectionAction = { (index: Int, item: String) in
        
            var buttonConfiguration = UIButton.Configuration.plain()
            buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0)
            
            var attributedTitle = AttributedString(item)
            attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 14)
            attributedTitle.foregroundColor = UIColor.appColor(.neutral800)
            buttonConfiguration.attributedTitle = attributedTitle
            button.configuration = buttonConfiguration

            if let imageView = button.subviews.compactMap({ $0 as? UIImageView }).first {
                imageView.image = UIImage.appImage(symbol: .chevronDown)
                NSLayoutConstraint.activate([
                    imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
                    imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
                ])
            }
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
