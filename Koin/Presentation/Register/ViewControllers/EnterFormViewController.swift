//
//  EnterFormViewController.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit
import Combine
import DropDown

final class EnterFormViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    private let inputSubject: PassthroughSubject<RegisterFormViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView()
    
    private let stepTextLabel = UILabel().then {
        $0.text = "4. 정보 입력"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let stepLabel = UILabel().then {
        $0.text = "4 / 4"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let progressView = UIProgressView().then {
        $0.trackTintColor = UIColor.appColor(.neutral200)
        $0.progressTintColor = UIColor.appColor(.primary500)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.progress = 1

        NSLayoutConstraint.activate([
            $0.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    private let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
        $0.backgroundColor = UIColor.appColor(.neutral300)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
    }
    
    private let idLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "사용하실 아이디를 입력해 주세요."
    }

    private let idTextField = DefaultTextField(
        placeholder: "5~13자리로 입력해 주세요.",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 14)
    )
    
    private let checkIdDuplicateButton = StatefulButton(
        title: "중복 확인",
        font: .appFont(.pretendardRegular, size: 10),
        enabledColor: .appColor(.primary500),
        disabledColor: .appColor(.neutral300),
        cornerRadius: 4
    ).then {
        $0.updateState(isEnabled: false)
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
    
    private let passwordTextField1 = DefaultTextField(
        placeholder: "특수문자 포함 영어와 숫자 6~18자리로 입력해주세요.",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 13)
    ).then {
        $0.isSecureTextEntry = true
    }
    
    private let passwordInfoLabel: UILabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "올바른 비밀번호 양식이 아닙니다. 다시 입력해 주세요.", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.sub500))
        $0.isHidden = true
    }
    
    private let passwordTextField2 = DefaultTextField(
        placeholder: "비밀번호를 다시 입력해 주세요.",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 13)
    ).then {
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
            title: "학부를 선택해주세요.",
            font: UIFont.appFont(.pretendardRegular, size: 14),
            titleColor: .appColor(.neutral400),
            borderColor: .white,
            backgroundColor: .appColor(.neutral0),
            icon: UIImage.appImage(symbol: .chevronDown)
        )
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.06
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowRadius = 4
        $0.layer.cornerRadius = 12
        $0.isHidden = true
    }
    
    private let deptDropDown = DropDown().then {
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    
    private let studentIdTextField = DefaultTextField(
        placeholder: "학번을 입력해주세요.",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 14)
    ).then {
        $0.isHidden = true
    }
    
    private let studentIdWarningLabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "올바른 학번 양식이 아닙니다. 다시 입력해 주세요.", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.sub500))
        $0.isHidden = true
    }
    
    private let nicknameTextField = DefaultTextField(
        placeholder: "닉네임은 변경 가능합니다. (선택)",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 14)
    ).then {
        $0.isHidden = true
    }
    
    private let nicknameDuplicateButton = StatefulButton(
        title: "중복 확인",
        font: .appFont(.pretendardRegular, size: 10),
        enabledColor: .appColor(.primary500),
        disabledColor: .appColor(.neutral300),
        cornerRadius: 4
    ).then {
        $0.updateState(isEnabled: false)
        $0.isHidden = true
    }
    
    private let nicknameResponseLabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "중복된 닉네임입니다. 다시 입력해 주세요.", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.sub500))
        $0.isHidden = true
    }
    
    private let studentEmailTextField = DefaultTextField(
        placeholder: "koreatech 이메일(선택)",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 14)
    ).then {
        $0.isHidden = true
    }
    
    private let koreatechEmailLabel = UILabel().then {
        $0.text = "@koreatech.ac.kr"
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral400)
        $0.isHidden = true
    }
    
    private let generalEmailTextField = DefaultTextField(
        placeholder: "이메일을 입력해 주세요. (선택)",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 14)
    ).then {
        $0.isHidden = true
    }
    
    private let generalEmailResponseLabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "올바른 이메일 형식이 아닙니다. 다시 입력해 주세요.", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.sub500))
        $0.isHidden = true
    }
    
    // MARK: - Init
    init(viewModel: RegisterFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setUpButtonTargets()
        bind()
        inputSubject.send(.getDeptList)
        hideKeyboardWhenTappedAround()
        addKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
        addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpTextFieldUnderline()
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case let .showIdHttpResult(message, color):
                guard !message.isEmpty else { return }
                self?.checkIdResponseLabel.isHidden = false
                self?.checkIdResponseLabel.setImageText(
                    image: UIImage.appImage(asset: .warningOrange),
                    text: message,
                    font: UIFont.appFont(.pretendardRegular, size: 12),
                    textColor: .appColor(.sub500)
                )
            case .successCheckDuplicatedId:
                self?.checkIdResponseLabel.isHidden = false
                self?.checkIdResponseLabel.setImageText(
                    image: UIImage.appImage(asset: .checkGreenCircle),
                    text: "사용 가능한 아이디입니다.",
                    font: UIFont.appFont(.pretendardRegular, size: 12),
                    textColor: .appColor(.success700)
                    )
                self?.checkIdDuplicateButton.updateState(isEnabled: false)
                let customSessionId = CustomSessionManager.getOrCreateSessionId(eventName: "sign_up", userId: 0, platform: "iOS")
                self?.inputSubject.send(.logSessionEvent(EventParameter.EventLabel.User.createAccount, .click, "아이디 생성", customSessionId))
            case let .showDeptDropDownList(deptList):
                self?.setUpDropDown(dropDown: strongSelf.deptDropDown, button: strongSelf.departmentDropdownButton, dataSource: deptList)
            case let .showNicknameHttpResult(message, color):
                self?.nicknameResponseLabel.isHidden = false
                self?.nicknameResponseLabel.setImageText(
                    image: UIImage.appImage(asset: .warningOrange),
                    text: message,
                    font: UIFont.appFont(.pretendardRegular, size: 12),
                    textColor: .appColor(.sub500)
                )
            case .changeCheckButtonStatus:
                self?.nicknameDuplicateButton.updateState(isEnabled: false)
                self?.nicknameResponseLabel.setImageText(
                    image: .appImage(asset: .checkGreenCircle),
                    text: "사용 가능한 닉네임입니다.",
                    font: .appFont(.pretendardRegular, size: 12),
                    textColor: .appColor(.success700))
                let customSessionId = CustomSessionManager.getOrCreateSessionId(eventName: "sign_up", userId: 0, platform: "iOS")
                self?.inputSubject.send(.logSessionEvent(EventParameter.EventLabel.User.createAccount, .click, "닉네임 생성", customSessionId))
            case let .showUserType(type):
                self?.configureUserTypeSpecificUI(for: type)
            case .succesRegister:
                let viewController = RegisterCompletionViewController()
                viewController.title = "회원가입"
                self?.navigationController?.pushViewController(viewController, animated: true)
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    private func setUpButtonTargets() {
        idTextField.addTarget(self, action: #selector(idTextFieldDidChange(_:)), for: .editingChanged)
        checkIdDuplicateButton.addTarget(self, action: #selector(checkDuplicateButtonTapped), for: .touchUpInside)
        passwordTextField1.setRightToggleButton(image: .appImage(asset: .visibility), target: self, action: #selector(changeSecureButtonTapped1))
        passwordTextField1.addTarget(self, action: #selector(passwordTextField1DidChange(_:)), for: .editingChanged)
        passwordTextField1.delegate = self
        passwordTextField2.setRightToggleButton(image: .appImage(asset: .visibility), target: self, action: #selector(changeSecureButtonTapped2))
        passwordTextField2.addTarget(self, action: #selector(passwordTextField2DidChange(_:)), for: .editingChanged)
        passwordTextField2.delegate = self
        departmentDropdownButton.addTarget(self, action: #selector(departmentButtonTapped(_:)), for: .touchUpInside)
        studentIdTextField.setRightButton(image: UIImage.appImage(asset: .cancelNeutral500), target: self, action: #selector(clearStudentIdTextField))
        studentIdTextField.addTarget(self, action: #selector(studentIdTextFieldDidChange(_:)), for: .editingChanged)
        nicknameTextField.setRightButton(image: UIImage.appImage(asset: .cancelNeutral500), target: self, action: #selector(clearStudentNicknameTextField))
        nicknameTextField.addTarget(self, action: #selector(nicknameTextFieldDidChange(_:)), for: .editingChanged)
        nicknameDuplicateButton.addTarget(self, action: #selector(checkStudentNicknameDuplicateButtonTapped), for: .touchUpInside)
        studentEmailTextField.addTarget(self, action: #selector(studentEmailTextFieldDidChange(_:)), for: .editingChanged)
        generalEmailTextField.addTarget(self, action: #selector(generalEmailTextFieldDidChange(_:)), for: .editingChanged)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    func tryRegister() {
        guard let loginId = idTextField.text,
              let password = passwordTextField1.text,
              let userType = viewModel.userType else { return }

        let nicknameText = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let nickname = (nicknameText?.isEmpty == true) ? nil : nicknameText

        switch userType {
        case .student:
            guard let dept = departmentDropdownButton.titleLabel?.text,
                  let studentNumber = studentIdTextField.text else { return }

            let emailText = studentEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = (emailText?.isEmpty == true) ? nil : emailText

            let request = StudentRegisterFormRequest(
                name: viewModel.tempName ?? "",
                phoneNumber: viewModel.tempPhoneNumber ?? "",
                loginId: loginId,
                password: password,
                department: dept,
                studentNumber: studentNumber,
                gender: viewModel.tempGender ?? "",
                email: email,
                nickname: nickname
            )

            viewModel.transform(with: Just(.tryStudentRegister(request)).eraseToAnyPublisher())
                .sink { _ in }.store(in: &subscriptions)

        case .general:
            let emailText = generalEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = (emailText?.isEmpty == true) ? nil : emailText

            let request = GeneralRegisterFormRequest(
                name: viewModel.tempName ?? "",
                phoneNumber: viewModel.tempPhoneNumber ?? "",
                loginId: loginId,
                gender: viewModel.tempGender ?? "",
                password: password,
                email: email,
                nickname: nickname
            )

            viewModel.transform(with: Just(.tryGeneralRegister(request)).eraseToAnyPublisher())
                .sink { _ in }.store(in: &subscriptions)
        }
    }
}

extension EnterFormViewController {
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        scrollView.contentInset.bottom = keyboardFrame.height
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
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

        checkIdDuplicateButton.updateState(isEnabled: isValid)
    }
    
    @objc private func passwordTextField1DidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        let isValid = textField.isValidPasswordFormat()

        passwordInfoLabel.isHidden = isValid
        passwordTextField2.isHidden = !isValid
    }
    
    @objc private func passwordTextField2DidChange(_ textField: UITextField) {
        guard let firstText = passwordTextField1.text,
              let secondText = passwordTextField2.text else { return }

        if firstText == secondText {
            correctPasswordLabel.isHidden = false

            if let userType = viewModel.userType {
                configureUserTypeSpecificUI(for: userType)
            }
        } else {
            correctPasswordLabel.isHidden = true
        }
    }
    
    @objc private func checkDuplicateButtonTapped() {
        guard let loginId = idTextField.text else { return }
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
    
    @objc func departmentButtonTapped(_ sender: UIButton) {
        self.view.layoutIfNeeded()
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
        let isValid = isLengthValid && isYearValid
        studentIdWarningLabel.isHidden = isValid
        
        if isValid {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.appColor(.primary500)
            nextButton.setTitleColor(.white, for: .normal)
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.appColor(.neutral300)
            nextButton.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        }
    }
    
    @objc private func clearStudentNicknameTextField() {
        nicknameTextField.text = nil
    }
    
    @objc private func nicknameTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        let trimmedText = String(text.prefix(10))
        textField.text = trimmedText

        let isValid = !trimmedText.isEmpty && trimmedText.count <= 10
        nicknameDuplicateButton.updateState(isEnabled: isValid)
    }
    
    @objc private func checkStudentNicknameDuplicateButtonTapped() {
        guard let nicknameText = nicknameTextField.text else { return }
        inputSubject.send(.checkDuplicatedNickname(nicknameText))
        nicknameResponseLabel.isHidden = false
    }
    
    @objc private func studentEmailTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789._-")
        let filteredText = text.filter { String($0).rangeOfCharacter(from: allowedCharacterSet) != nil }
        let trimmedText = String(filteredText.prefix(30))
        textField.text = trimmedText
    }
    
    @objc private func generalEmailTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let trimmedText = String(text.prefix(30))
        textField.text = trimmedText

        generalEmailResponseLabel.isHidden = trimmedText.isValidEmailFormat
    }
    
    @objc private func nextButtonTapped() {
        guard let userType = viewModel.userType else { return }

        let loginId = idTextField.text ?? ""
        let password = passwordTextField2.text ?? ""
        let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNickname = (nickname?.isEmpty == true) ? nil : nickname

        switch userType {
        case .student:
            let department = departmentDropdownButton.titleLabel?.text ?? ""
            let studentNumber = studentIdTextField.text ?? ""

            let emailInput = studentEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = (emailInput?.isEmpty == true) ? nil : emailInput

            let request = StudentRegisterFormRequest(
                name: viewModel.tempName ?? "",
                phoneNumber: viewModel.tempPhoneNumber ?? "",
                loginId: loginId,
                password: password,
                department: department,
                studentNumber: studentNumber,
                gender: viewModel.tempGender ?? "",
                email: email,
                nickname: finalNickname
            )

            inputSubject.send(.tryStudentRegister(request))

        case .general:
            let emailInput = generalEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = (emailInput?.isEmpty == true) ? nil : emailInput

            let request = GeneralRegisterFormRequest(
                name: viewModel.tempName ?? "",
                phoneNumber: viewModel.tempPhoneNumber ?? "",
                loginId: loginId,
                gender: viewModel.tempGender ?? "",
                password: password,
                email: email,
                nickname: finalNickname
            )

            inputSubject.send(.tryGeneralRegister(request))
        }
    }
}

extension EnterFormViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= 18
    }
}

// MARK: UI Settings
extension EnterFormViewController {
    private func setUpLayouts() {
        [stepTextLabel, stepLabel, progressView, nextButton].forEach {
            view.addSubview($0)
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [idLabel, idTextField, checkIdDuplicateButton,
         checkIdResponseLabel, passwordLabel, passwordTextField1,
         passwordInfoLabel, passwordTextField2, correctPasswordLabel,
         studentInfoGuideLabel, departmentDropdownButton, deptDropDown,
         studentIdTextField, studentIdWarningLabel, nicknameTextField,
         nicknameDuplicateButton, nicknameResponseLabel, studentEmailTextField,
         koreatechEmailLabel, generalEmailTextField, generalEmailResponseLabel
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpBaseConstraints() {
        stepTextLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }

        stepLabel.snp.makeConstraints {
            $0.top.equalTo(stepTextLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(stepTextLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(3)
        }

        nextButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-40)
            $0.height.equalTo(50)
            $0.horizontalEdges.equalToSuperview().inset(32)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(nextButton.snp.top).offset(-32)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualToSuperview()
        }
        
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
            $0.width.equalTo(86)
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
        
        passwordInfoLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField1.snp.bottom)
            $0.leading.equalTo(passwordTextField1.snp.leading)
            $0.trailing.equalTo(passwordTextField1.snp.trailing)
            $0.height.equalTo(20)
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
    }
    
    private func setUpStudentConstraints() {
        studentInfoGuideLabel.snp.makeConstraints {
            $0.top.equalTo(correctPasswordLabel.snp.bottom).offset(32)
            $0.leading.equalTo(passwordLabel.snp.leading)
            $0.height.equalTo(29)
        }
        
        departmentDropdownButton.snp.makeConstraints {
            $0.top.equalTo(studentInfoGuideLabel.snp.bottom).offset(8)
            $0.leading.equalTo(studentInfoGuideLabel.snp.leading)
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
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(studentIdTextField.snp.bottom).offset(8)
            $0.leading.equalTo(departmentDropdownButton.snp.leading)
            $0.trailing.equalTo(nicknameDuplicateButton.snp.leading).offset(-16)
            $0.height.equalTo(40)
        }
        
        nicknameDuplicateButton.snp.makeConstraints {
            $0.centerY.equalTo(nicknameTextField.snp.centerY)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(32)
            $0.width.lessThanOrEqualTo(86)
        }
        
        nicknameResponseLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom)
            $0.leading.equalTo(nicknameTextField.snp.leading)
            $0.height.equalTo(20)
        }
        
        studentEmailTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            $0.leading.equalTo(departmentDropdownButton.snp.leading)
            $0.trailing.equalToSuperview().offset(-126)
            $0.height.equalTo(40)
        }
        
        koreatechEmailLabel.snp.makeConstraints {
            $0.centerY.equalTo(studentEmailTextField.snp.centerY)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(22)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func setUpGeneralConstraints() {
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(correctPasswordLabel.snp.bottom).offset(32)
            $0.leading.equalTo(passwordTextField2.snp.leading)
            $0.trailing.equalTo(nicknameDuplicateButton.snp.leading).offset(-16)
            $0.height.equalTo(40)
        }
        
        nicknameDuplicateButton.snp.makeConstraints {
            $0.centerY.equalTo(nicknameTextField.snp.centerY)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(32)
            $0.width.lessThanOrEqualTo(86)
        }
        
        nicknameResponseLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom)
            $0.leading.equalTo(nicknameTextField.snp.leading)
            $0.height.equalTo(20)
        }
        
        generalEmailTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            $0.leading.equalTo(nicknameTextField.snp.leading)
            $0.trailing.equalTo(nicknameDuplicateButton.snp.trailing)
            $0.height.equalTo(40)
        }
        
        generalEmailResponseLabel.snp.makeConstraints {
            $0.top.equalTo(generalEmailTextField.snp.bottom)
            $0.leading.equalTo(generalEmailTextField.snp.leading)
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().offset(-165)
        }
    }
    
    private func configureUserTypeSpecificUI(for userType: RegisterFormViewModel.UserType) {
        switch userType {
        case .student:
            [studentInfoGuideLabel, departmentDropdownButton, deptDropDown,
             studentIdTextField, nicknameTextField, nicknameDuplicateButton,
             studentEmailTextField, koreatechEmailLabel].forEach {
                $0.isHidden = false
            }
            setUpStudentConstraints()

        case .general:
            [nicknameTextField, nicknameDuplicateButton, generalEmailTextField].forEach {
                $0.isHidden = false
            }
            setUpGeneralConstraints()

            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.appColor(.primary500)
            nextButton.setTitleColor(.white, for: .normal)
        }

        view.layoutIfNeeded()
        setUpTextFieldUnderline()
    }
    
    private func setUpTextFieldUnderline() {
        [idTextField, passwordTextField1, passwordTextField2, studentIdTextField, nicknameTextField, studentEmailTextField, generalEmailTextField].forEach {
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
            attributedTitle.foregroundColor = UIColor.appColor(.neutral500)
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
        view.backgroundColor = .white
        setUpLayouts()
        setUpBaseConstraints()
    }
}
