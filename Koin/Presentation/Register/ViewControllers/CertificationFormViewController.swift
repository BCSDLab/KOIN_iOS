//
//  CertificationFormViewController.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit
import Combine

final class CertificationFormViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    private let inputSubject: PassthroughSubject<RegisterFormViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var timer: Timer?
    private var remainingSeconds: Int = 180

    // MARK: - UI Components
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView()
    
    private let stepTextLabel = UILabel().then {
        $0.text = "2. 본인 인증"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let stepLabel = UILabel().then {
        $0.text = "2 / 4"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let progressView = UIProgressView().then {
        $0.trackTintColor = UIColor.appColor(.neutral200)
        $0.progressTintColor = UIColor.appColor(.primary500)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.progress = 0.5

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

    private let nameAndGenderLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "성함과 성별을 알려주세요."
    }
    
    private let nameTextField = DefaultTextField(
        placeholder: "2~5 자리로 입력해 주세요.",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 14)
    )
    
    private let nameHelpLabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "올바른 양식이 아닙니다. 다시 입력해 주세요.", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.sub500))
        $0.isHidden = true
    }
    
    private let femaleButton = UIButton().then {
        $0.applyRadioStyle(title: "여성", font: .appFont(.pretendardRegular, size: 16), image: .appImage(asset: .circlePrimary500), foregroundColor: .black)
    }
    
    private let maleButton = UIButton().then {
        $0.applyRadioStyle(title: "남성", font: .appFont(.pretendardRegular, size: 16), image: .appImage(asset: .circlePrimary500), foregroundColor: .black)
    }
    
    private let phoneNumberLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "휴대전화 번호를 입력해 주세요."
        $0.isHidden = true
    }
    
    private let phoneNumberTextField = DefaultTextField(
        placeholder: "- 없이 번호를 입력해 주세요.",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 14)
    ).then {
        $0.isHidden = true
    }
    
    private let sendVerificationButton = StatefulButton(
        title: "인증번호 발송",
        font: .appFont(.pretendardRegular, size: 10),
        enabledColor: .appColor(.primary500),
        disabledColor: .appColor(.neutral300),
        cornerRadius: 4
    ).then {
        $0.updateState(isEnabled: false)
        $0.isHidden = true
    }

    private let phoneNumberReponseLabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.danger700))
        $0.numberOfLines = 2
        $0.isHidden = true
    }
    
    let goToLoginButton = UIButton().then {
        $0.setTitle("로그인 하기", for: .normal)
        $0.setTitleColor(.appColor(.primary500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.isHidden = true
    }
    
    private let phoneNotFoundLabel = UILabel().then {
        $0.text = "해당 전화번호로 가입하신 적 없으신가요?"
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.isHidden = true
    }
    
    private let contactButton = UIButton().then {
        $0.setTitle("문의하기", for: .normal)
        $0.setTitleColor(.appColor(.primary500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.isHidden = true
    }
    
    private let verificationTextField = DefaultTextField(
        placeholder: "인증번호를 입력해주세요.",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 14)
    ).then {
        $0.isHidden = true
    }
    
    private let timerLabel = UILabel().then {
        $0.text = "03:00"
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private let verificationButton = StatefulButton(
        title: "인증번호 확인",
        font: .appFont(.pretendardRegular, size: 10),
        enabledColor: .appColor(.primary500),
        disabledColor: .appColor(.neutral300),
        cornerRadius: 4
    ).then {
        $0.updateState(isEnabled: false)
        $0.isHidden = true
    }
    
    private let verificationHelpLabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.danger700))
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
        hideKeyboardWhenTappedAround()
        addKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
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
            guard self != nil else { return }
            switch output {
            case let .showHttpResult(message, labelColor):
                if let verificationCode = self?.verificationTextField.text, !verificationCode.isEmpty {
                    self?.showVerificationHelpResult(message, labelColor)
                } else {
                    self?.showHttpResult(message, labelColor)
                }
            case .changeSendVerificationButtonStatus:
                self?.phoneNumberReponseLabel.isHidden = true
                self?.sendVerificationButton.updateState(isEnabled: true)
            case let .sendVerificationCodeSuccess(response):
                self?.handleSendVerificationCodeSuccess(response: response)
            case .correctVerificationCode:
                self?.verificationHelpLabel.isHidden = false
                self?.timer?.invalidate()
                self?.timer = nil
                self?.timerLabel.isHidden = true
                self?.sendVerificationButton.updateState(isEnabled: false)
                self?.verificationButton.updateState(isEnabled: false)
                self?.verificationHelpLabel.setImageText(
                    image: UIImage.appImage(asset: .checkGreenCircle),
                    text: "인증번호가 일치합니다.",
                    font: UIFont.appFont(.pretendardRegular, size: 12),
                    textColor: UIColor.appColor(.success700)
                )
                self?.contactButton.isHidden = true
                self?.viewModel.tempName = self?.nameTextField.text
                self?.viewModel.tempPhoneNumber = self?.phoneNumberTextField.text
                self?.viewModel.tempGender = self?.femaleButton.configuration?.image == UIImage.appImage(asset: .circleCheckedPrimary500) ? "1" : "0"
                self?.nextButton.isEnabled = true
                self?.nextButton.backgroundColor = UIColor.appColor(.primary500)
                self?.nextButton.setTitleColor(.white, for: .normal)
                let customSessionId = CustomSessionManager.getOrCreateSessionId(duration: .fifteenMinutes, eventName: "sign_up", loginStatus: 0, platform: "iOS")
                self?.inputSubject.send(.logEventWithSessionId(EventParameter.EventLabel.User.identityVerification, .click, "인증완료", customSessionId))
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    private func setUpButtonTargets() {
        nameTextField.setRightButton(image: UIImage.appImage(asset: .cancelNeutral500), target: self, action: #selector(clearNameTextField))
        nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
        femaleButton.addTarget(self, action: #selector(femaleButtonTapped), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(maleButtonTapped), for: .touchUpInside)
        phoneNumberTextField.setRightButton(image: UIImage.appImage(asset: .cancelNeutral500), target: self, action: #selector(clearPhoneNumberTextField))
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChange(_:)), for: .editingChanged)
        sendVerificationButton.addTarget(self, action: #selector(sendVerificationButtonTapped), for: .touchUpInside)
        contactButton.addTarget(self, action: #selector(contactButtonButtonTapped), for: .touchUpInside)
        verificationTextField.addTarget(self, action: #selector(verificationTextFieldDidChange(_:)), for: .editingChanged)
        verificationButton.addTarget(self, action: #selector(verificationButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
}

extension CertificationFormViewController {
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
    
    @objc private func clearNameTextField() {
        nameTextField.text = ""
    }
    
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        var koreanCount = 0
        var englishCount = 0
        var result = ""

        for character in text {
            if let scalar = character.unicodeScalars.first {
                let value = scalar.value

                if (0xAC00...0xD7A3).contains(value) {
                    if koreanCount >= 5 { break }
                    koreanCount += 1
                    result.append(character)
                } else if CharacterSet.letters.contains(scalar) {
                    if englishCount >= 30 { break }
                    englishCount += 1
                    result.append(character)
                } else {
                    if koreanCount >= 5 { break }
                    koreanCount += 1
                    result.append(character)
                }
            }
        }

        textField.text = result

        if koreanCount + englishCount <= 1 {
            nameHelpLabel.isHidden = false
        } else {
            nameHelpLabel.isHidden = true
            updatePhoneNumberSectionVisibility()
        }
    }
    
    @objc private func femaleButtonTapped() {
        updateGenderSelection(isFemale: true)
        updatePhoneNumberSectionVisibility()
    }

    @objc private func maleButtonTapped() {
        updateGenderSelection(isFemale: false)
        updatePhoneNumberSectionVisibility()
    }
    
    private func updateGenderSelection(isFemale: Bool) {
        var femaleConfig = femaleButton.configuration
        var maleConfig = maleButton.configuration

        femaleConfig?.image = UIImage.appImage(asset: isFemale ? .circleCheckedPrimary500 : .circlePrimary500)
        maleConfig?.image = UIImage.appImage(asset: isFemale ? .circlePrimary500 : .circleCheckedPrimary500)

        femaleButton.configuration = femaleConfig
        maleButton.configuration = maleConfig
    }
    
    private func updatePhoneNumberSectionVisibility() {
        let nameCount = nameTextField.text?.count ?? 0
        let isNameValid = (2...5).contains(nameCount)
        let isGenderSelected = (femaleButton.configuration?.image == UIImage.appImage(asset: .circleCheckedPrimary500)) || (maleButton.configuration?.image == UIImage.appImage(asset: .circleCheckedPrimary500))
        
        let shouldShowPhoneFields = isNameValid && isGenderSelected
        
        phoneNumberLabel.isHidden = !shouldShowPhoneFields
        phoneNumberTextField.isHidden = !shouldShowPhoneFields
        sendVerificationButton.isHidden = !shouldShowPhoneFields
    }
    
    @objc private func clearPhoneNumberTextField() {
        phoneNumberTextField.text = ""
        sendVerificationButton.updateState(isEnabled: false)
        [goToLoginButton, phoneNotFoundLabel, contactButton, phoneNumberReponseLabel].forEach {
            $0.isHidden = true
        }
    }
    
    @objc private func phoneNumberTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let filteredText = text.filter { $0.isNumber }
        if filteredText.count > 11 {
            textField.text = String(filteredText.prefix(11))
        } else {
            textField.text = filteredText
        }
        
        if textField.text?.isEmpty ?? true {
            phoneNumberReponseLabel.isHidden = true
            sendVerificationButton.updateState(isEnabled: false)
        }
        
        inputSubject.send(.checkDuplicatedPhoneNumber(textField.text ?? ""))
    }
    
    @objc private func verificationTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let filteredText = text.filter { $0.isNumber }
        if filteredText.count > 6 {
            textField.text = String(filteredText.prefix(6))
        } else {
            textField.text = filteredText
        }
        changeVerificationButtonStatus(textField.text ?? "")
    }
    
    private func showVerificationHelpResult(_ message: String, _ color: SceneColorAsset) {
        verificationHelpLabel.isHidden = false
        verificationHelpLabel.setImageText(
            image: UIImage.appImage(asset: .warningOrange),
            text: message,
            font: UIFont.appFont(.pretendardRegular, size: 12),
            textColor: UIColor.appColor(color)
        )
    }
    
    private func changeVerificationButtonStatus(_ text: String) {
        if text.count == 6 {
            verificationButton.updateState(isEnabled: true)
        } else {
            verificationButton.updateState(isEnabled: true)
        }
    }
    
    private func showHttpResult(_ message: String, _ color: SceneColorAsset) {
        phoneNumberReponseLabel.isHidden = false
        
        if message == "이미 존재하는 전화번호입니다." {
            phoneNumberReponseLabel.setImageText(image: .appImage(asset: .warningRed), text: message, font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.danger600))
            [goToLoginButton, phoneNotFoundLabel, contactButton].forEach {
                $0.isHidden = false
            }
        } else {
            phoneNumberReponseLabel.setImageText(image: .appImage(asset: .warningOrange), text: message, font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(color))
            [goToLoginButton, phoneNotFoundLabel, contactButton].forEach {
                $0.isHidden = true
            }
        }
    }
    
    @objc private func contactButtonButtonTapped() {
        guard let url = URL(string: "https://open.kakao.com/o/sgiYx4Qg") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func sendVerificationButtonTapped() {
        timer?.invalidate()
        remainingSeconds = 180
        startTimer()

        [contactButton, verificationTextField, timerLabel, verificationButton].forEach { $0.isHidden = true }
        
        sendVerificationButton.setTitle("인증번호 재발송", for: .normal)
        verificationHelpLabel.text = "인증번호 발송이 안 되시나요?"
        verificationHelpLabel.font = UIFont.appFont(.pretendardRegular, size: 12)
        verificationHelpLabel.textColor = UIColor.appColor(.neutral500)
        
        guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else {
            return
        }
        
        inputSubject.send(.sendVerificationCode(phoneNumber))
        let customSessionId = CustomSessionManager.getOrCreateSessionId(duration: .fifteenMinutes, eventName: "sign_up", loginStatus: 0, platform: "iOS")
        inputSubject.send(.logEventWithSessionId(EventParameter.EventLabel.User.identityVerification, .click, "인증번호 발송", customSessionId))
    }
    
    private func startTimer() {
        timerLabel.text = formatTime(remainingSeconds)
        verificationHelpLabel.isHidden = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                self.timerLabel.text = self.formatTime(self.remainingSeconds)
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.verificationHelpLabel.isHidden = false
                self.verificationHelpLabel.setImageText(image: .appImage(asset: .warningOrange), text: "유효시간이 지났습니다. 인증번호를 재발송 해주세요.", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.sub500))
            }
        }
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func handleSendVerificationCodeSuccess(response: SendVerificationCodeDto) {
        [verificationTextField, timerLabel, verificationButton, phoneNumberReponseLabel].forEach { $0.isHidden = false }

        phoneNumberReponseLabel.setImageAttributedText(image: .appImage(asset: .checkGreenCircle), attributedText: makeVerificationMessage(remainingCount: response.remainingCount, totalCount: response.totalCount))
        
        verificationTextField.text = ""
        verificationButton.updateState(isEnabled: false)
        
        if response.currentCount > 1 {
            [verificationHelpLabel, contactButton].forEach { $0.isHidden = false }
            contactButton.snp.remakeConstraints {
                $0.centerY.equalTo(verificationHelpLabel.snp.centerY)
                $0.leading.equalTo(verificationHelpLabel.snp.trailing).offset(8)
                $0.height.greaterThanOrEqualTo(19)
                $0.width.greaterThanOrEqualTo(42)
            }
        } else {
            [verificationHelpLabel, contactButton].forEach { $0.isHidden = true }
        }
        
        verificationTextField.becomeFirstResponder()
    }
    
    private func makeVerificationMessage(remainingCount: Int, totalCount: Int) -> NSAttributedString {
        let fullText = "인증번호가 발송되었습니다.  남은 횟수 (\(remainingCount)/\(totalCount))"
        let attributedString = NSMutableAttributedString(string: fullText)
        if let successRange = fullText.range(of: "인증번호가 발송되었습니다.") {
            let nsRange = NSRange(successRange, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.success700), range: nsRange)
        }
        
        if let countRange = fullText.range(of: "남은 횟수 (\(remainingCount)/\(totalCount))") {
            let nsRange = NSRange(countRange, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.neutral500), range: nsRange)
        }
        attributedString.addAttribute(.font, value: UIFont.appFont(.pretendardRegular, size: 12), range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    
    @objc private func verificationButtonTapped() {
        if let verificationText = verificationTextField.text, let phoneNumber = phoneNumberTextField.text {
            inputSubject.send(.checkVerificationCode(phoneNumber, verificationText))
        } else {
            return
        }
    }
    
    @objc private func nextButtonTapped() {
        let viewController = SelectTypeFormViewController(viewModel: viewModel)
        viewController.title = "회원가입"
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: UI Settings
extension CertificationFormViewController {
    private func setUpLayouts() {
        [stepTextLabel, stepLabel, progressView, nextButton].forEach {
            view.addSubview($0)
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [nameAndGenderLabel, nameTextField, nameHelpLabel, femaleButton, maleButton, phoneNumberLabel, phoneNumberTextField, sendVerificationButton, phoneNumberReponseLabel, goToLoginButton, phoneNotFoundLabel, contactButton, verificationTextField, timerLabel, verificationButton, verificationHelpLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
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
        
        nameAndGenderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(29)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameAndGenderLabel.snp.bottom).offset(16)
            $0.leading.equalTo(nameAndGenderLabel.snp.leading)
            $0.trailing.equalTo(nameAndGenderLabel.snp.trailing)
            $0.height.equalTo(40)
        }
        
        nameHelpLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom)
            $0.leading.equalTo(nameTextField.snp.leading)
            $0.trailing.equalTo(nameTextField.snp.trailing)
            $0.height.equalTo(20)
        }
        
        femaleButton.snp.makeConstraints {
            $0.top.equalTo(nameHelpLabel.snp.bottom).offset(10)
            $0.leading.equalTo(nameTextField.snp.leading).offset(-5)
            $0.height.equalTo(26)
            $0.width.greaterThanOrEqualTo(52)
        }
        
        maleButton.snp.makeConstraints {
            $0.top.equalTo(femaleButton.snp.top)
            $0.leading.equalTo(femaleButton.snp.trailing).offset(32)
            $0.height.equalTo(26)
            $0.width.greaterThanOrEqualTo(52)
        }
        
        phoneNumberLabel.snp.makeConstraints {
            $0.top.equalTo(femaleButton.snp.bottom).offset(64)
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(29)
        }
        
        phoneNumberTextField.snp.makeConstraints {
            $0.top.equalTo(phoneNumberLabel.snp.bottom).offset(8)
            $0.leading.equalTo(phoneNumberLabel.snp.leading)
            $0.trailing.equalTo(phoneNumberLabel.snp.trailing).offset(-102)
            $0.height.equalTo(40)
        }
        
        sendVerificationButton.snp.makeConstraints {
            $0.centerY.equalTo(phoneNumberTextField.snp.centerY)
            $0.leading.equalTo(phoneNumberTextField.snp.trailing).offset(16)
            $0.trailing.equalTo(phoneNumberLabel.snp.trailing)
            $0.height.equalTo(32)
        }
        
        phoneNumberReponseLabel.snp.makeConstraints {
            $0.top.equalTo(phoneNumberTextField.snp.bottom)
            $0.leading.equalTo(phoneNumberTextField.snp.leading).offset(4)
            $0.trailing.equalTo(sendVerificationButton.snp.trailing)
            $0.height.greaterThanOrEqualTo(20)
        }
        
        goToLoginButton.snp.makeConstraints {
            $0.centerY.equalTo(phoneNumberReponseLabel.snp.centerY)
            $0.leading.equalTo(phoneNumberReponseLabel.snp.trailing).offset(8)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(55)
        }
        
        phoneNotFoundLabel.snp.makeConstraints {
            $0.top.equalTo(phoneNumberReponseLabel.snp.bottom).offset(8)
            $0.leading.equalTo(phoneNumberReponseLabel.snp.leading)
            $0.height.equalTo(19)
        }
        
        contactButton.snp.makeConstraints {
            $0.centerY.equalTo(phoneNotFoundLabel.snp.centerY)
            $0.leading.equalTo(phoneNotFoundLabel.snp.trailing).offset(8)
            $0.height.greaterThanOrEqualTo(19)
            $0.width.greaterThanOrEqualTo(42)
        }
        
        verificationTextField.snp.makeConstraints {
            $0.top.equalTo(phoneNumberReponseLabel.snp.bottom).offset(24)
            $0.leading.equalTo(phoneNumberTextField.snp.leading)
            $0.trailing.equalTo(phoneNumberTextField.snp.trailing)
            $0.height.equalTo(40)
        }
        
        timerLabel.snp.makeConstraints {
            $0.centerY.equalTo(verificationTextField.snp.centerY)
            $0.trailing.equalTo(verificationTextField.snp.trailing).offset(4)
            $0.width.greaterThanOrEqualTo(39)
            $0.height.equalTo(22)
        }
        
        verificationButton.snp.makeConstraints {
            $0.centerY.equalTo(verificationTextField.snp.centerY)
            $0.leading.equalTo(verificationTextField.snp.trailing).offset(16)
            $0.trailing.equalTo(sendVerificationButton.snp.trailing)
            $0.height.equalTo(32)
        }
        
        verificationHelpLabel.snp.makeConstraints {
            $0.top.equalTo(verificationTextField.snp.bottom).offset(8)
            $0.leading.equalTo(verificationTextField.snp.leading).offset(4)
            $0.height.equalTo(19)
        }
    }
    
    private func setUpTextFieldUnderline() {
        [nameTextField, phoneNumberTextField, verificationTextField].forEach {
            $0.setUnderline(color: .appColor(.neutral300), thickness: 1, leftPadding: 0, rightPadding: 0)
        }
    }
    
    private func configureView() {
        view.backgroundColor = .white
        setUpLayouts()
        setUpConstraints()
    }
}
