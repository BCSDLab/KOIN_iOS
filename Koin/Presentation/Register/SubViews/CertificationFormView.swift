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
    
    // MARK: - UI Components
    private let nameAndGenderLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "성함과 성별을 알려주세요."
    }
    
    private let nameTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(string: "2~5 자리로 입력해 주세요.", attributes: [.foregroundColor: UIColor.appColor(.neutral400), .font: UIFont.appFont(.pretendardRegular, size: 14)])
        $0.autocapitalizationType = .none
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.clearButtonMode = .never
        let clearButton = UIButton(type: .custom) // 커스텀 버튼
        clearButton.setImage(UIImage.appImage(asset: .cancelNeutral500), for: .normal)
        clearButton.addTarget(self, action: #selector(clearNameTextField), for: .touchUpInside)
        clearButton.tintColor = .red
        $0.rightView = clearButton
        $0.rightViewMode = .whileEditing
        $0.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    private let seperateView1 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    private lazy var femaleButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .circlePrimary500)
        var text = AttributedString("여성")
        text.font = UIFont.appFont(.pretendardRegular, size: 16)
        configuration.attributedTitle = text
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .black
        $0.configuration = configuration
        $0.addTarget(self, action: #selector(femaleButtonTapped), for: .touchUpInside)
    }
    
    private lazy var maleButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .circlePrimary500)
        var text = AttributedString("남성")
        text.font = UIFont.appFont(.pretendardRegular, size: 16)
        configuration.attributedTitle = text
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .black
        $0.configuration = configuration
        $0.addTarget(self, action: #selector(maleButtonTapped), for: .touchUpInside)
    }
    
    private let phoneNumberLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "휴대전화 번호를 입력해 주세요."
        $0.isHidden = true
    }
    
    private let phoneNumberTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(string: "- 없이 번호를 입력해 주세요.", attributes: [.foregroundColor: UIColor.appColor(.neutral400), .font: UIFont.appFont(.pretendardRegular, size: 14)])
        $0.autocapitalizationType = .none
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)

        $0.clearButtonMode = .never
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage.appImage(asset: .cancelNeutral500), for: .normal)
        clearButton.addTarget(self, action: #selector(clearPhoneNumberTextField), for: .touchUpInside)
        $0.rightView = clearButton
        $0.rightViewMode = .whileEditing
        
        $0.addTarget(self, action: #selector(phoneNumberTextFieldDidChange(_:)), for: .editingChanged)
        $0.isHidden = true
    }
    
    private let seperateView2 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
        $0.isHidden = true
    }
    
    private let sendVerificationButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral300)
        $0.setTitle("인증번호 발송", for: .normal)
        $0.setTitleColor(.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 10)
        $0.layer.cornerRadius = 4
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(sendVerificationButtonTapped), for: .touchUpInside)
        $0.isHidden = true
    }

    private let warningImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .warningOrange)
        $0.isHidden = true
    }

    private let phoneNumberReponseLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
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
        $0.addTarget(self, action: #selector(contactButtonButtonTapped), for: .touchUpInside)
    }
    
    private let verificationTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(string: "인증번호를 입력해주세요.", attributes: [.foregroundColor: UIColor.appColor(.neutral400), .font: UIFont.appFont(.pretendardRegular, size: 14)])
        $0.autocapitalizationType = .none
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
    
    private let seperateView3 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
        $0.isHidden = true
    }
    
    private let verificationButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral300)
        $0.setTitle("인증번호 확인", for: .normal)
        $0.setTitleColor(.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 10)
        $0.layer.cornerRadius = 4
        $0.isHidden = true
        $0.addTarget(self, action: #selector(verificationButtonTapped), for: .touchUpInside)
    }
    
    private let verificationHelpLabel = UILabel().then {
        $0.text = "인증번호 발송이 안 되시나요?"
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
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
                self?.showHttpResult(message, labelColor)
            case .changeSendVerificationButtonStatus:
                self?.warningImageView.isHidden = true
                self?.phoneNumberReponseLabel.isHidden = true
                self?.sendVerificationButton.isEnabled = true
                self?.sendVerificationButton.backgroundColor = .appColor(.primary500)
                self?.sendVerificationButton.setTitleColor(.white, for: .normal)
            case let .sendVerificationCodeSuccess(response):
                self?.handleSendVerificationCodeSuccess(response: response)
                self?.verificationTextField.isHidden = false
                self?.timerLabel.isHidden = false
                self?.seperateView3.isHidden = false
                self?.verificationButton.isHidden = false
                self?.verificationHelpLabel.isHidden = false
            case .correctVerificationCode:
                self?.verificationHelpLabel.textColor = .appColor(.success700)
                self?.verificationHelpLabel.text = "인증번호가 일치합니다."
            }
        }.store(in: &subscriptions)
    }
}

extension CertificationFormView {
    @objc private func clearNameTextField() {
        nameTextField.text = nil
    }
    
    @objc private func clearPhoneNumberTextField() {
        phoneNumberTextField.text = nil
        sendVerificationButton.isEnabled = false
        sendVerificationButton.backgroundColor = .appColor(.neutral300)
        sendVerificationButton.setTitleColor(.appColor(.neutral600), for: .normal)
        goToLoginButton.isHidden = true
        phoneNotFoundLabel.isHidden = true
        contactButton.isHidden = true
        warningImageView.isHidden = true
        phoneNumberReponseLabel.isHidden = true
    }
    
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count > 5 {
            textField.text = String(text.prefix(5))
        }
        updatePhoneNumberSectionVisibility()
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
            warningImageView.isHidden = true
            phoneNumberReponseLabel.isHidden = true
            sendVerificationButton.isEnabled = false
            sendVerificationButton.backgroundColor = .appColor(.neutral300)
            sendVerificationButton.setTitleColor(.appColor(.neutral600), for: .normal)
        }
        
        inputSubject.send(.checkDuplicatedPhoneNumber(textField.text ?? ""))
    }
    
    private func updatePhoneNumberSectionVisibility() {
        let nameCount = nameTextField.text?.count ?? 0
        let isNameValid = (2...5).contains(nameCount)
        let isGenderSelected = (femaleButton.configuration?.image == UIImage.appImage(asset: .circleCheckedPrimary500)) ||
                                (maleButton.configuration?.image == UIImage.appImage(asset: .circleCheckedPrimary500))
        
        let shouldShowPhoneFields = isNameValid && isGenderSelected
        
        phoneNumberLabel.isHidden = !shouldShowPhoneFields
        phoneNumberTextField.isHidden = !shouldShowPhoneFields
        seperateView2.isHidden = !shouldShowPhoneFields
        sendVerificationButton.isHidden = !shouldShowPhoneFields
    }
    
    @objc private func femaleButtonTapped() {
        updateGenderSelection(isFemale: true)
        updatePhoneNumberSectionVisibility()
    }

    @objc private func maleButtonTapped() {
        updateGenderSelection(isFemale: false)
        updatePhoneNumberSectionVisibility()
    }
    
    private func showHttpResult(_ message: String, _ color: SceneColorAsset) {
        warningImageView.isHidden = false
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

        verificationTextField.isHidden = false
        timerLabel.isHidden = false
        seperateView3.isHidden = false
        verificationButton.isHidden = false
        
        sendVerificationButton.setTitle("인증번호 재발송", for: .normal)
        
        if let phoneNumber = phoneNumberTextField.text {
            print("📮 [View] 보내는 전화번호: \(phoneNumber)")
            inputSubject.send(.sendVerificationCode(phoneNumber))
        } else {
            print("❌ [View] 전화번호가 비어 있음")
        }
    }
    
    private func startTimer() {
        timerLabel.text = formatTime(remainingSeconds)
        verificationHelpLabel.isHidden = true // 처음엔 숨기기
        
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
        seperateView3.isHidden = false
        verificationButton.isHidden = false
        warningImageView.isHidden = false
        warningImageView.image = UIImage.appImage(asset: .checkGreenCircle)
        
        phoneNumberReponseLabel.isHidden = false
        phoneNumberReponseLabel.attributedText = makeVerificationMessage(
            remainingCount: response.remainingCount,
            totalCount: response.totalCount
        )
        
        if (response.currentCount > 1) {
            verificationHelpLabel.isHidden = false
            
            contactButton.snp.makeConstraints {
                $0.centerY.equalTo(verificationHelpLabel.snp.centerY)
                $0.leading.equalTo(verificationHelpLabel.snp.trailing).offset(8)
                $0.height.greaterThanOrEqualTo(19)
                $0.width.greaterThanOrEqualTo(42)
            }
        }
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
            print("❌ [View] 인증번호 비어 있음")
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
        [nameAndGenderLabel, nameTextField, seperateView1, femaleButton, maleButton, phoneNumberLabel, phoneNumberTextField, seperateView2, sendVerificationButton, warningImageView, phoneNumberReponseLabel, goToLoginButton, phoneNotFoundLabel, contactButton, verificationTextField, timerLabel, seperateView3, verificationButton, verificationHelpLabel].forEach {
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
        
        seperateView1.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom)
            $0.leading.equalTo(nameTextField.snp.leading)
            $0.trailing.equalTo(nameTextField.snp.trailing)
            $0.height.equalTo(1)
        }
        
        femaleButton.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(16)
            $0.leading.equalTo(seperateView1.snp.leading)
            $0.height.equalTo(26)
            $0.width.greaterThanOrEqualTo(52)
        }
        
        maleButton.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(16)
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
        
        seperateView2.snp.makeConstraints {
            $0.top.equalTo(phoneNumberTextField.snp.bottom)
            $0.leading.equalTo(phoneNumberTextField.snp.leading)
            $0.trailing.equalTo(phoneNumberTextField.snp.trailing)
            $0.height.equalTo(1)
        }
        
        sendVerificationButton.snp.makeConstraints {
            $0.centerY.equalTo(phoneNumberTextField.snp.centerY)
            $0.leading.equalTo(phoneNumberTextField.snp.trailing).offset(16)
            $0.trailing.equalTo(phoneNumberLabel.snp.trailing)
            $0.height.equalTo(32)
        }
        
        warningImageView.snp.makeConstraints {
            $0.top.equalTo(seperateView2.snp.bottom).offset(9.5)
            $0.leading.equalTo(seperateView2.snp.leading).offset(4)
            $0.width.height.equalTo(16)
        }
        
        phoneNumberReponseLabel.snp.makeConstraints {
            $0.centerY.equalTo(warningImageView.snp.centerY)
            $0.leading.equalTo(warningImageView.snp.trailing).offset(4)
            $0.height.greaterThanOrEqualTo(19)
        }
        
        goToLoginButton.snp.makeConstraints {
            $0.centerY.equalTo(phoneNumberReponseLabel.snp.centerY)
            $0.leading.equalTo(phoneNumberReponseLabel.snp.trailing).offset(8)
            $0.height.greaterThanOrEqualTo(19)
            $0.width.greaterThanOrEqualTo(55)
        }
        
        phoneNotFoundLabel.snp.makeConstraints {
            $0.top.equalTo(phoneNumberReponseLabel.snp.bottom).offset(8)
            $0.leading.equalTo(warningImageView.snp.leading)
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
            $0.trailing.equalTo(seperateView3.snp.trailing).offset(4)
            $0.width.greaterThanOrEqualTo(39)
            $0.height.equalTo(22)
        }
        
        seperateView3.snp.makeConstraints {
            $0.top.equalTo(verificationTextField.snp.bottom)
            $0.leading.equalTo(phoneNumberTextField.snp.leading)
            $0.trailing.equalTo(phoneNumberTextField.snp.trailing)
            $0.height.equalTo(1)
        }
        
        verificationButton.snp.makeConstraints {
            $0.centerY.equalTo(verificationTextField.snp.centerY)
            $0.leading.equalTo(seperateView3.snp.trailing).offset(16)
            $0.trailing.equalTo(sendVerificationButton.snp.trailing)
            $0.height.equalTo(32)
        }
        
        verificationHelpLabel.snp.makeConstraints {
            $0.top.equalTo(seperateView3.snp.bottom).offset(8)
            $0.leading.equalTo(seperateView3.snp.leading).offset(4)
            $0.height.equalTo(19)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
