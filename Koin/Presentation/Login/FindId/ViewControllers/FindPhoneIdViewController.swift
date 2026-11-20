//
//  FindPhoneIdViewController.swift
//  koin
//
//  Created by 김나훈 on 6/17/25.
//

import Combine
import UIKit

final class FindPhoneIdViewController: UIViewController {
    
    enum CertType {
        case phone
        case email
    }
    // MARK: - Properties
    private let viewModel: FindIdViewModel
    private let certType: CertType
    private var subscriptions: Set<AnyCancellable> = []
    @Published private var remainCount = 5
    private var timer: AnyCancellable?
    private let verificationTimer = VerificationTimer()
    private var sendPolicy = VerificationSendPolicy()
    private var isVerifyingCode = false
    private var sendRequestedAt: Date?
    
    // MARK: - UI Components
    
    private lazy var phoneNumberLabel = UILabel().then {
        $0.text = certType == .phone ? "휴대전화 번호" : "이메일"
    }
    
    private lazy var phoneNumberTextField = DefaultTextField(
        placeholder: certType == .phone ? "- 없이 번호를 입력해 주세요." : "등록된 이메일을 입력해 주세요.",
        placeholderColor: UIColor.appColor(.neutral400),
        font: UIFont.appFont(.pretendardRegular, size: 14)
    ).then {
        $0.keyboardType = certType == .phone ? .numberPad : .emailAddress
    }
    
    private let sendButton = StateButton().then {
        $0.setState(state: .unusable)
        $0.setTitle("인증번호 발송", for: .normal)
    }
    
    private let helpLabel = UILabel().then {
        $0.text = "휴대전화 등록을 안 하셨나요?"
    }
    
    private let changeButton = UIButton().then {
        $0.setTitle("이메일로 찾기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.new500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 12)
    }
    
    private let phoneStateView = StateView().then {
        $0.isHidden = true
    }
    
    private let remainCountLabel = UILabel().then {
        $0.text = "남은 횟수 (4/5)"
        $0.isHidden = true
    }
    
    private let certNumberTextField = DefaultTextField(placeholder: "인증번호를 입력해주세요.", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14)).then {
        $0.keyboardType = .numberPad
    }
    
    private let remainTimeLabel = UILabel().then {
        $0.text = "05:00"
        $0.isHidden = true
    }
    
    private let certNumberButton = StateButton().then {
        $0.setState(state: .unusable)
        $0.setTitle("인증번호 확인", for: .normal)
    }
    
    private let certNumberLoadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.color = .white
        $0.hidesWhenStopped = true
    }
    
    private let certNumberStateView = StateView()
    
    private let saveButton = StateButton(font: UIFont.appFont(.pretendardMedium, size: 16)).then {
        $0.setState(state: .unusable)
        $0.setTitle("저장", for: .normal)
    }.then {
        $0.layer.cornerRadius = 8
    }
    
    init(viewModel: FindIdViewModel, certType: CertType = .phone) {
        self.viewModel = viewModel
        self.certType = certType
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "아이디 찾기"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        hideKeyboardWhenTappedAround()
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        certNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        certNumberButton.addTarget(self, action: #selector(certNumberButtonTapped), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpTextFieldUnderline()
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.sendMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self else { return }
            if response.1 {
                handleSendVerificationEmailSuccess(message: response.0)
            } else {
                handleSendVerificationCodeFailure(message: response.0)
            }
        }.store(in: &subscriptions)

        viewModel.sendVerificationCodeSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.handleSendVerificationCodeSuccess(response: response)
        }.store(in: &subscriptions)

        viewModel.verificationCodeAcceptedPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            guard let self, isVerifyingCode else { return }
            timer?.cancel()
            timer = nil
        }.store(in: &subscriptions)

        viewModel.checkVerificationCodeFailurePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self, isVerifyingCode else { return }
            handleCheckVerificationCodeFailure(statusCode: response.0, message: response.1)
        }.store(in: &subscriptions)
        
        viewModel.checkMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self, isVerifyingCode else { return }
            updateVerifyingState(false)
            if response.1 {
                view.endEditing(true)
                certNumberTextField.isUserInteractionEnabled = false
            }
            certNumberStateView.isHidden = false
            if !response.1 {
                if timer == nil {
                    if sendPolicy.canVerify(at: Date()) {
                        startVerificationTimer()
                    } else {
                        endVerificationSession()
                    }
                }
                certNumberStateView.setState(state: .warning, message: response.0)
            } else {
                certNumberStateView.setState(state: .success, message: response.0)
                saveButton.setState(state: .usable)
                certNumberButton.setState(state: .unusable)
                timer?.cancel()
                timer = nil
                remainTimeLabel.isHidden = true
            }
        }.store(in: &subscriptions)
    }
}

extension FindPhoneIdViewController {
    private func startVerificationTimer() {
        guard let sentAt = sendPolicy.lastSentAt else { return }

        timer?.cancel()
        remainTimeLabel.text = verificationTimer.formattedRemainingTime(at: Date(), sentAt: sentAt)
        remainTimeLabel.isHidden = false

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self = self else { return }
                if !self.verificationTimer.isExpired(at: now, sentAt: sentAt) {
                    self.remainTimeLabel.text = self.verificationTimer.formattedRemainingTime(at: now, sentAt: sentAt)
                } else {
                    self.endVerificationSession()
                    self.certNumberStateView.setState(state: .warning, message: "유효시간이 지났습니다. 인증번호를 재발송 해주세요.")
                    self.certNumberStateView.isHidden = false
                }
            }
    }

    private func handleSendVerificationCodeSuccess(response: SendVerificationCodeDto) {
        phoneStateView.setVerificationSentState(remainingCount: response.remainingCount, totalCount: response.totalCount)
        startVerificationSession()
    }

    private func handleSendVerificationEmailSuccess(message: String) {
        phoneStateView.setState(state: .success, message: message)
        startVerificationSession()
    }

    private func startVerificationSession() {
        sendPolicy.markSent(at: sendRequestedAt ?? Date())
        startVerificationTimer()

        phoneStateView.isHidden = false
        certNumberStateView.isHidden = true
        certNumberTextField.text = ""
        updateVerificationInputState()
    }

    private func handleSendVerificationCodeFailure(message: String) {
        let certificationError = CertificationError(message: message)
        if certificationError.blocksResend {
            sendPolicy.blockByDailyLimit()
        }
        phoneStateView.setState(state: certificationError.blocksResend ? .dangerous : .warning, message: message)
        phoneStateView.isHidden = false
        unlockSendVerification()
    }

    private func handleCheckVerificationCodeFailure(statusCode: Int?, message: String) {
        sendPolicy.recordVerifyFailure(statusCode: statusCode)

        updateVerifyingState(false)

        if !sendPolicy.hasRemainingVerifyAttempts {
            endVerificationSession()
        }

        certNumberStateView.isHidden = false
        certNumberStateView.setState(state: .warning, message: sendPolicy.verifyFailureMessage(statusCode: statusCode, serverMessage: message))
    }

    private func updateSendButtonState() {
        let canSend = isInputComplete && sendPolicy.canSend(at: Date())
        sendButton.setState(state: canSend ? .usable : .unusable)
    }

    private var isInputComplete: Bool {
        let text = phoneNumberTextField.text ?? ""
        return certType == .phone ? PhoneNumberInput.isComplete(text) : EmailInput.isValid(text)
    }

    private func unlockSendVerification() {
        phoneNumberTextField.isUserInteractionEnabled = true
        updateSendButtonState()
    }

    private func updateVerificationInputState() {
        let canVerify = sendPolicy.canVerify(at: Date())

        if !canVerify {
            certNumberTextField.resignFirstResponder()
        }
        certNumberTextField.isUserInteractionEnabled = canVerify
        let isReady = canVerify && !isVerifyingCode && VerificationCodeInput.isReadyToConfirm(certNumberTextField.text ?? "")
        certNumberButton.setState(state: isReady ? .usable : .unusable)
    }

    private func updateVerifyingState(_ isVerifying: Bool) {
        isVerifyingCode = isVerifying
        certNumberButton.setTitle(isVerifying ? nil : "인증번호 확인", for: .normal)
        if isVerifying {
            certNumberLoadingIndicator.startAnimating()
        } else {
            certNumberLoadingIndicator.stopAnimating()
        }
        updateVerificationInputState()
    }

    private func endVerificationSession() {
        timer?.cancel()
        timer = nil
        remainTimeLabel.text = "00:00"
        if isVerifyingCode {
            viewModel.cancelCheckVerificationCode()
            updateVerifyingState(false)
        }
        unlockSendVerification()
        updateVerificationInputState()
    }

    @objc private func sendButtonTapped() {
        [helpLabel, changeButton].forEach {
            $0.isHidden = true
        }
        
        guard isInputComplete, sendPolicy.canSend(at: Date()) else { return }
        let input = phoneNumberTextField.text ?? ""

        timer?.cancel()
        sendRequestedAt = Date()
        phoneNumberTextField.resignFirstResponder()
        phoneNumberTextField.isUserInteractionEnabled = false
        sendButton.setState(state: .unusable)

        if certType == .phone {
            viewModel.sendVerificationCode(phoneNumber: input)
        } else {
            viewModel.sendVerificationEmail(email: input)
        }
    }
    @objc private func certNumberButtonTapped() {
        guard !isVerifyingCode else { return }
        updateVerifyingState(true)

        if certType == .phone {
            viewModel.checkVerificationCode(phoneNumber: phoneNumberTextField.text ?? "", code: certNumberTextField.text ?? "")
        } else {
            viewModel.checkVerificationEmail(email: phoneNumberTextField.text ?? "", code: certNumberTextField.text ?? "")
        }
    }
    @objc private func changeButtonTapped() {
        if var viewControllers = navigationController?.viewControllers {
            viewControllers.removeLast()
            let newVC = FindPhoneIdViewController(viewModel: viewModel, certType: .email)
            viewControllers.append(newVC)
            navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }
    @objc private func saveButtonTapped() {
        navigationController?.pushViewController(FoundIdViewController(viewModel: viewModel), animated: true)
    }
    @objc private func textFieldDidChange(textField: UITextField) {
        if textField == phoneNumberTextField {
            if certType == .phone {
                textField.text = PhoneNumberInput.acceptedDigits(from: textField.text ?? "")
            }
            updateSendButtonState()
        } else {
            textField.text = VerificationCodeInput.acceptedDigits(from: textField.text ?? "")
            updateVerificationInputState()
        }
    }
}

extension FindPhoneIdViewController {
    
    private func setupLayOuts() {
        [phoneNumberLabel, phoneNumberTextField, sendButton, helpLabel, changeButton, phoneStateView, remainCountLabel, certNumberTextField, remainTimeLabel, certNumberButton, certNumberStateView, saveButton].forEach {
            view.addSubview($0)
        }
        certNumberButton.addSubview(certNumberLoadingIndicator)
    }
    
    private func setupConstraints() {
        phoneNumberLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(64)
            $0.leading.equalTo(view.snp.leading).offset(32)
        }
        phoneNumberTextField.snp.makeConstraints {
            $0.top.equalTo(phoneNumberLabel.snp.bottom).offset(25)
            $0.leading.equalTo(phoneNumberLabel)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-16)
            $0.height.equalTo(40)
        }
        sendButton.snp.makeConstraints {
            $0.top.equalTo(phoneNumberTextField)
            $0.trailing.equalTo(view.snp.trailing).offset(-32)
            $0.width.equalTo(86)
            $0.height.equalTo(32)
        }
        phoneStateView.snp.makeConstraints {
            $0.top.equalTo(phoneNumberTextField.snp.bottom).offset(5)
            $0.leading.equalTo(phoneNumberTextField)
        }
        helpLabel.snp.makeConstraints {
            $0.top.equalTo(phoneNumberTextField.snp.bottom).offset(5)
            $0.leading.equalTo(phoneNumberLabel)
            $0.height.equalTo(19)
        }
        changeButton.snp.makeConstraints {
            $0.leading.equalTo(helpLabel.snp.trailing).offset(5)
            $0.centerY.equalTo(helpLabel)
            $0.width.equalTo(66)
            $0.height.equalTo(19)
        }
        remainCountLabel.snp.makeConstraints {
            $0.leading.equalTo(phoneStateView.snp.trailing).offset(5)
            $0.centerY.equalTo(phoneStateView)
        }
        certNumberTextField.snp.makeConstraints {
            $0.top.equalTo(phoneStateView.snp.bottom).offset(30)
            $0.leading.equalTo(phoneNumberLabel)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-16)
            $0.height.equalTo(40)
        }
        remainTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(certNumberTextField)
            $0.trailing.equalTo(certNumberTextField.snp.trailing).offset(-14)
        }
        certNumberButton.snp.makeConstraints {
            $0.top.equalTo(certNumberTextField)
            $0.trailing.equalTo(view.snp.trailing).offset(-32)
            $0.width.equalTo(86)
            $0.height.equalTo(32)
        }
        certNumberLoadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        certNumberStateView.snp.makeConstraints {
            $0.top.equalTo(certNumberTextField.snp.bottom).offset(8.5)
            $0.leading.equalTo(certNumberTextField)
        }
        saveButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(32)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }
    }
    
    private func setupComponents() {
        phoneNumberLabel.font = UIFont.appFont(.pretendardMedium, size: 18)
        phoneNumberLabel.textColor = .black
        remainCountLabel.font = UIFont.appFont(.pretendardRegular, size: 12)
        remainCountLabel.textColor = UIColor.appColor(.neutral500)
        remainTimeLabel.font = UIFont.appFont(.pretendardRegular, size: 14)
        remainTimeLabel.textColor = UIColor.appColor(.neutral500)
        helpLabel.font = UIFont.appFont(.pretendardRegular, size: 12)
        helpLabel.textColor = UIColor.appColor(.neutral500)
        [helpLabel, changeButton].forEach {
            $0.isHidden = certType == .email
        }
    }
    
    private func setUpTextFieldUnderline() {
        [phoneNumberTextField, certNumberTextField].forEach {
            $0.setUnderline(color: .appColor(.neutral300), thickness: 1, leftPadding: 0, rightPadding: 0)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
