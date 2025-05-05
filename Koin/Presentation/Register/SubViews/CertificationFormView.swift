//
//  CertificationFormView.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit
import Combine

final class CertificationFormView: UIView {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    private let inputSubject: PassthroughSubject<RegisterFormViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    private var timer: Timer?
    private var remainingSeconds: Int = 180
    var onVerificationStatusChanged: ((Bool) -> Void)?
    
    override var isHidden: Bool {
        didSet {
            if isHidden == false {
                self.onVerificationStatusChanged?(false)
            }
        }
    }

    // MARK: - UI Components
    private let nameAndGenderLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "성함과 성별을 알려주세요."
    }
    
    private let nameTextField = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "2~5 자리로 입력해 주세요.", textColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
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
    
    private let phoneNumberTextField = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "- 없이 번호를 입력해 주세요.", textColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.isHidden = true
    }
    
    private let sendVerificationButton = UIButton().then {
        $0.applyVerificationButtonStyle(title: "인증번호 발송", font: .appFont(.pretendardRegular, size: 10), cornerRadius: 4)
        $0.updateState(isEnabled: false, enabledColor: .appColor(.primary500), disabledColor: .appColor(.neutral300))
        $0.isHidden = true
    }

    private let phoneNumberReponseLabel = UILabel().then {
        $0.setImageText(image: .appImage(asset: .warningOrange), text: "", font: .appFont(.pretendardRegular, size: 12), textColor: .appColor(.danger700))
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
    
    private let verificationTextField = UITextField().then {
        $0.configureDefaultTextField()
        $0.setCustomPlaceholder(text: "인증번호를 입력해주세요.", textColor: UIColor.appColor(.neutral400), font: .appFont(.pretendardRegular, size: 14))
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.isHidden = true
    }
    
    private let timerLabel = UILabel().then {
        $0.text = "03:00"
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private let verificationButton = UIButton().then {
        $0.applyVerificationButtonStyle(title: "인증번호 확인", font: .appFont(.pretendardRegular, size: 10), cornerRadius: 4)
        $0.updateState(isEnabled: false, enabledColor: .appColor(.primary500), disabledColor: .appColor(.neutral300))
        $0.isHidden = true
    }
    
    private let verificationHelpLabel = UILabel().then {
        $0.isHidden = true
    }
    
    // MARK: Init
    init(viewModel: RegisterFormViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureView()
        setAddTarget()
        bind()
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
                self?.sendVerificationButton.updateState(isEnabled: true, enabledColor: .appColor(.primary500), disabledColor: .appColor(.neutral300))
                
            case let .sendVerificationCodeSuccess(response):
                self?.handleSendVerificationCodeSuccess(response: response)
                
            case .correctVerificationCode:
                self?.verificationHelpLabel.isHidden = false
                self?.verificationHelpLabel.setImageText(
                    image: UIImage.appImage(asset: .checkGreenCircle),
                    text: "인증번호가 일치합니다.",
                    font: UIFont.appFont(.pretendardRegular, size: 12),
                    textColor: UIColor.appColor(.success700)
                )
                self?.contactButton.isHidden = true
                self?.onVerificationStatusChanged?(true)
                
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    private func setAddTarget() {
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
    }
}

extension CertificationFormView {
    @objc private func clearNameTextField() {
        nameTextField.text = ""
    }
    
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count > 5 {
            textField.text = String(text.prefix(5))
        }
        updatePhoneNumberSectionVisibility()
    }
    
    @objc private func femaleButtonTapped() {
        updateGenderSelection(isFemale: true)
        updatePhoneNumberSectionVisibility()
    }

    @objc private func maleButtonTapped() {
        updateGenderSelection(isFemale: false)
        updatePhoneNumberSectionVisibility()
    }
    
    @objc private func clearPhoneNumberTextField() {
        phoneNumberTextField.text = ""
        sendVerificationButton.updateState(isEnabled: false, enabledColor: .appColor(.primary500), disabledColor: .appColor(.neutral300))
        goToLoginButton.isHidden = true
        phoneNotFoundLabel.isHidden = true
        contactButton.isHidden = true
        phoneNumberReponseLabel.isHidden = true
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
            sendVerificationButton.updateState(isEnabled: false, enabledColor: .appColor(.primary500), disabledColor: .appColor(.neutral300))
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
    
    private func updatePhoneNumberSectionVisibility() {
        let nameCount = nameTextField.text?.count ?? 0
        let isNameValid = (2...5).contains(nameCount)
        let isGenderSelected = (femaleButton.configuration?.image == UIImage.appImage(asset: .circleCheckedPrimary500)) || (maleButton.configuration?.image == UIImage.appImage(asset: .circleCheckedPrimary500))
        
        let shouldShowPhoneFields = isNameValid && isGenderSelected
        
        phoneNumberLabel.isHidden = !shouldShowPhoneFields
        phoneNumberTextField.isHidden = !shouldShowPhoneFields
        sendVerificationButton.isHidden = !shouldShowPhoneFields
    }
    
    private func changeVerificationButtonStatus(_ text: String) {
        if text.count == 6 {
            verificationButton.updateState(isEnabled: true, enabledColor: .appColor(.primary500), disabledColor: .appColor(.neutral300))
        } else {
            verificationButton.updateState(isEnabled: false, enabledColor: .appColor(.primary500), disabledColor: .appColor(.neutral300))
        }
    }
    
    private func showHttpResult(_ message: String, _ color: SceneColorAsset) {
        phoneNumberReponseLabel.isHidden = false
        phoneNumberReponseLabel.text = message
        phoneNumberReponseLabel.textColor = UIColor.appColor(color)
        
        if message == "이미 존재하는 전화번호입니다." {
            goToLoginButton.isHidden = false
            phoneNotFoundLabel.isHidden = false
            contactButton.isHidden = false
        } else {
            goToLoginButton.isHidden = true
            phoneNotFoundLabel.isHidden = true
            contactButton.isHidden = true
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

        verificationTextField.isHidden = true
        timerLabel.isHidden = true
        verificationButton.isHidden = true
        
        sendVerificationButton.setTitle("인증번호 재발송", for: .normal)
        verificationHelpLabel.text = "인증번호 발송이 안 되시나요?"
        verificationHelpLabel.font = UIFont.appFont(.pretendardRegular, size: 12)
        verificationHelpLabel.textColor = UIColor.appColor(.neutral500)
        
        if let phoneNumber = phoneNumberTextField.text {
            print("📮 [View] 보내는 전화번호: \(phoneNumber)")
            inputSubject.send(.sendVerificationCode(phoneNumber))
        } else {
            print("❌ [View] 전화번호가 비어 있음")
        }
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
                self.verificationHelpLabel.text = "유효시간이 지났습니다. 인증번호를 재발송 해주세요."
            }
        }
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func handleSendVerificationCodeSuccess(response: SendVerificationCodeDTO) {
        verificationTextField.isHidden = false
        timerLabel.isHidden = false
        verificationButton.isHidden = false
        
        phoneNumberReponseLabel.isHidden = false
        phoneNumberReponseLabel.attributedText = makeVerificationMessage(
            remainingCount: response.remainingCount,
            totalCount: response.totalCount
        )
        
        verificationTextField.text = ""
        
        verificationButton.isEnabled = false
        verificationButton.backgroundColor = .appColor(.neutral300)
        verificationButton.setTitleColor(.appColor(.neutral600), for: .normal)
        
        if response.currentCount >= 2 {
            verificationHelpLabel.isHidden = false
            contactButton.isHidden = false
            contactButton.snp.remakeConstraints {
                $0.centerY.equalTo(verificationHelpLabel.snp.centerY)
                $0.leading.equalTo(verificationHelpLabel.snp.trailing).offset(8)
                $0.height.greaterThanOrEqualTo(19)
                $0.width.greaterThanOrEqualTo(42)
            }
        } else {
            verificationHelpLabel.isHidden = true
            contactButton.isHidden = true
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
            print("📮 [View] 보내는 전화번호 및 인증번호: \(phoneNumber), \(verificationText)")
            inputSubject.send(.checkVerificationCode(phoneNumber, verificationText))
        } else {
            print("인증번호 비어 있음")
        }
    }

    private func updateGenderSelection(isFemale: Bool) {
        var femaleConfig = femaleButton.configuration
        var maleConfig = maleButton.configuration

        femaleConfig?.image = UIImage.appImage(asset: isFemale ? .circleCheckedPrimary500 : .circlePrimary500)
        maleConfig?.image = UIImage.appImage(asset: isFemale ? .circlePrimary500 : .circleCheckedPrimary500)

        femaleButton.configuration = femaleConfig
        maleButton.configuration = maleConfig

        // 선택된 성별을 ViewModel에 저장할 때 여기서 처리하기
        // viewModel.selectedGender = isFemale ? .female : .male
    }
}

// MARK: UI Settings
extension CertificationFormView {
    private func setUpLayOuts() {
        [nameAndGenderLabel, nameTextField, femaleButton, maleButton, phoneNumberLabel, phoneNumberTextField, sendVerificationButton, phoneNumberReponseLabel, goToLoginButton, phoneNotFoundLabel, contactButton, verificationTextField, timerLabel, verificationButton, verificationHelpLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
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
        
        femaleButton.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(16)
            $0.leading.equalTo(nameTextField.snp.leading)
            $0.height.equalTo(26)
            $0.width.greaterThanOrEqualTo(52)
        }
        
        maleButton.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(16)
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
            $0.height.equalTo(20)
        }
        
        goToLoginButton.snp.makeConstraints {
            $0.centerY.equalTo(phoneNumberReponseLabel.snp.centerY)
            $0.leading.equalTo(phoneNumberReponseLabel.snp.trailing).offset(8)
            $0.height.greaterThanOrEqualTo(19)
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
        setUpLayOuts()
        setUpConstraints()
    }
}
