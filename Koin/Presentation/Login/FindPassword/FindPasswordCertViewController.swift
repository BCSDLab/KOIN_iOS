//
//  FindPasswordCertViewController.swift
//  koin
//
//  Created by 김나훈 on 6/19/25.
//

import Combine
import UIKit

final class FindPasswordCertViewController: UIViewController {
    
    // MARK: - Properties
    enum CertType {
        case email
        case phone
    }
    private let certType: CertType
    private let viewModel: FindPasswordViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private var timer: AnyCancellable?
    private let verificationTimer = VerificationTimer()
    private var sendPolicy = VerificationSendPolicy()
    private var isVerifyingCode = false
    private var sendRequestedAt: Date?
    
    // MARK: - UI Components
    
    private let stepTextLabel = UILabel().then {
        $0.text = "1. 계정 인증"
        $0.textColor = UIColor.appColor(.new500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let stepLabel = UILabel().then {
        $0.text = "1 / 2"
        $0.textColor = UIColor.appColor(.new500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let progressView = UIProgressView().then {
        $0.trackTintColor = UIColor.appColor(.neutral200)
        $0.progressTintColor = UIColor.appColor(.new500)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.progress = 0.5

        NSLayoutConstraint.activate([
            $0.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    private let idLabel = UILabel().then {
        $0.text = "아이디"
    }
    
    private let idtextField = DefaultTextField(placeholder: "아이디를 입력해주세요.", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
    
    private let idStateView = StateView().then {
        $0.isHidden = true
    }
    
    private lazy var phoneLabel = UILabel().then {
        $0.text = certType == .phone ? "휴대전화 번호" : "이메일"
    }
    
    private lazy var phoneTextField = DefaultTextField(placeholder: certType == .phone ? "휴대전화 번호" : "등록한 이메일을 입력해주세요", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
    
    private let sendButton = StateButton(title: "인증번호 발송")
    
    private lazy var helpLabel = UILabel().then {
        $0.text = "휴대전화 등록을 안 하셨나요?"
        $0.isHidden = certType == .phone ? false : true
    }
    
    private lazy var changeButton = UIButton().then {
        $0.setTitle("이메일로 찾기", for: .normal)
        $0.isHidden = certType == .phone ? false : true
    }
    
    private let phoneStateView = StateView().then {
        $0.isHidden = true
    }
    
    private let certNumberTextField = DefaultTextField(placeholder: "인증번호를 입력해주세요.", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14)).then {
        $0.isHidden = true
    }
    
    private let remainTimeLabel = UILabel().then {
        $0.isHidden = true
    }
    
    private let certNumberCheckButton = StateButton(title: "인증번호 확인").then {
        $0.setState(state: .unusable)
        $0.isHidden = true
    }
    
    private let certNumberLoadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.color = .white
        $0.hidesWhenStopped = true
    }
    
    private let certNumberStateView = StateView().then {
        $0.isHidden = true
    }
    
    private let saveButton = StateButton(font: UIFont.appFont(.pretendardMedium, size: 15)).then {
        $0.setTitle("다음", for: .normal)
        $0.setState(state: .unusable)
    }
    
    init(viewModel: FindPasswordViewModel, certType: CertType = .phone) {
        self.viewModel = viewModel
        self.certType = certType
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "비밀번호 찾기"
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
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
        certNumberCheckButton.addTarget(self, action: #selector(certNumberCheckButtonTapped), for: .touchUpInside)
        
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        certNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        idtextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpTextFieldUnderline()
    }
    // MARK: - Bind
    
    private func bind() {
        
        viewModel.$inputData.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] text in
            guard let self = self else { return }
            if certType == .phone {
                updateSendButtonState()
                return
            }
            sendButton.setState(state: text.isEmpty ? .unusable : .usable)
        }.store(in: &subscriptions)
        
        viewModel.$certNumber.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] text in
            guard let self = self else { return }
            if certType == .phone {
                updateVerificationInputState()
                return
            }
            certNumberCheckButton.setState(state: text.isEmpty ? .unusable : .usable)
        }.store(in: &subscriptions)
        
        viewModel.sendMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self = self else { return }
            if certType == .phone {
                handleSendVerificationCodeFailure(message: response.0)
                return
            }
            phoneStateView.isHidden = false
            phoneStateView.setState(state: response.1 ? .success : .warning, message: response.0)
            if response.1 {
                startTimer()
                [certNumberTextField, remainTimeLabel, certNumberCheckButton].forEach {
                    $0.isHidden = false
                }
            }
        }.store(in: &subscriptions)
        
        viewModel.sendVerificationCodeSuccessPublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.handleSendVerificationCodeSuccess(response: response)
        }.store(in: &subscriptions)

        viewModel.checkVerificationCodeFailurePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self = self, isVerifyingCode else { return }
            handleCheckVerificationCodeFailure(statusCode: response.0, message: response.1)
        }.store(in: &subscriptions)
        
        viewModel.checkMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self = self else { return }
            if certType == .phone {
                guard isVerifyingCode else { return }
                updateVerifyingState(false)
                if response.1 {
                    view.endEditing(true)
                    certNumberTextField.isUserInteractionEnabled = false
                    certNumberCheckButton.setState(state: .unusable)
                }
            }
            certNumberStateView.isHidden = false
            certNumberStateView.setState(state: response.1 ? .success : .warning, message: response.0)
            if response.1 {
                if let idText = idtextField.text, !idText.isEmpty {
                    saveButton.setState(state: .usable)
                }
                timer?.cancel()
                timer = nil
                remainTimeLabel.isHidden = true
            }
        }.store(in: &subscriptions)
    }
}

extension FindPasswordCertViewController {
    private func startTimer() {
        guard let sentAt = sendPolicy.lastSentAt else { return }

        timer?.cancel()
        remainTimeLabel.text = verificationTimer.formattedRemainingTime(at: Date(), sentAt: sentAt)
        
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
        sendPolicy.markSent(at: sendRequestedAt ?? Date())
        startTimer()

        phoneStateView.isHidden = false
        phoneStateView.setVerificationSentState(remainingCount: response.remainingCount, totalCount: response.totalCount)
        certNumberStateView.isHidden = true
        certNumberTextField.text = ""
        viewModel.certNumber = ""
        [certNumberTextField, remainTimeLabel, certNumberCheckButton].forEach {
            $0.isHidden = false
        }
        updateVerificationInputState()
    }

    private func handleSendVerificationCodeFailure(message: String) {
        let certificationError = CertificationError(message: message)
        if certificationError.blocksResend {
            sendPolicy.blockByDailyLimit()
        }
        phoneStateView.isHidden = false
        phoneStateView.setState(state: certificationError.blocksResend ? .dangerous : .warning, message: message)
        unlockSendVerification()
    }

    private func handleCheckVerificationCodeFailure(statusCode: Int?, message: String) {
        if statusCode == 400 {
            sendPolicy.markVerifyFailed()
        } else if statusCode == 404 {
            sendPolicy.discardVerificationCode()
        }

        updateVerifyingState(false)

        if !sendPolicy.hasRemainingVerifyAttempts {
            endVerificationSession()
        }

        certNumberStateView.isHidden = false
        if statusCode == 400 && !sendPolicy.hasRemainingVerifyAttempts {
            certNumberStateView.setState(state: .warning, message: "인증번호를 여러 번 틀렸어요. 인증번호를 다시 받아 주세요.")
        } else {
            certNumberStateView.setState(state: .warning, message: message)
        }
    }

    private func updateSendButtonState() {
        let canSend = PhoneNumberInput.isComplete(phoneTextField.text ?? "") && sendPolicy.canSend(at: Date())
        sendButton.setState(state: canSend ? .usable : .unusable)
    }

    private func unlockSendVerification() {
        phoneTextField.isUserInteractionEnabled = true
        updateSendButtonState()
    }

    private func updateVerificationInputState() {
        let isExpired = sendPolicy.lastSentAt.map { verificationTimer.isExpired(at: Date(), sentAt: $0) } ?? true
        let canVerify = !isExpired && sendPolicy.hasRemainingVerifyAttempts

        if !canVerify {
            certNumberTextField.resignFirstResponder()
        }
        certNumberTextField.isUserInteractionEnabled = canVerify
        let isReady = canVerify && !isVerifyingCode && VerificationCodeInput.isReadyToConfirm(certNumberTextField.text ?? "")
        certNumberCheckButton.setState(state: isReady ? .usable : .unusable)
    }

    private func updateVerifyingState(_ isVerifying: Bool) {
        isVerifyingCode = isVerifying
        certNumberCheckButton.setTitle(isVerifying ? nil : "인증번호 확인", for: .normal)
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
        switch certType {
        case .phone:
            guard PhoneNumberInput.isComplete(phoneTextField.text ?? ""),
                  sendPolicy.canSend(at: Date()) else { return }

            timer?.cancel()
            sendRequestedAt = Date()
            phoneTextField.resignFirstResponder()
            phoneTextField.isUserInteractionEnabled = false
            sendButton.setState(state: .unusable)
            viewModel.sendVerificationCode()
        case .email: viewModel.sendVerificationEmail()
        }
    }
    @objc private func saveButtonTapped() {
        navigationController?.pushViewController(FindPasswordChangeViewController(viewModel: viewModel, certType: certType), animated: true)
    }
    @objc private func changeButtonTapped() {
        if var viewControllers = navigationController?.viewControllers {
            viewControllers.removeLast()
            let newVC = FindPasswordCertViewController(viewModel: viewModel, certType: .email)
            viewControllers.append(newVC)
            navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }
    @objc private func certNumberCheckButtonTapped() {
        switch certType {
        case .phone:
            guard !isVerifyingCode else { return }
            updateVerifyingState(true)
            viewModel.checkVerificationCode()
        case .email: viewModel.checkVerificationEmail()
        }
    }
    @objc private func textFieldDidChange(textField: UITextField) {
        if textField == phoneTextField {
            if certType == .phone {
                textField.text = PhoneNumberInput.acceptedDigits(from: textField.text ?? "")
            }
            viewModel.inputData = textField.text ?? ""
        } else if textField == certNumberTextField {
            if certType == .phone {
                textField.text = VerificationCodeInput.acceptedDigits(from: textField.text ?? "")
            }
            viewModel.certNumber = textField.text ?? ""
        } else if textField == idtextField {
            viewModel.id = textField.text ?? ""
        }
    }
}

extension FindPasswordCertViewController {
    
    private func setupLayOuts() {
        [stepTextLabel, stepLabel, progressView, idLabel, idtextField, idStateView, phoneLabel, phoneTextField, sendButton, helpLabel, changeButton, phoneStateView, certNumberTextField, remainTimeLabel, certNumberCheckButton, certNumberStateView, saveButton
        ].forEach {
            view.addSubview($0)
        }
        certNumberCheckButton.addSubview(certNumberLoadingIndicator)
    }

    private func setupConstraints() {
        stepTextLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
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
        idLabel.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(64)
            $0.leading.equalTo(stepTextLabel)
        }
        idtextField.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.height.equalTo(32)
        }
        idStateView.snp.makeConstraints {
            $0.top.equalTo(idtextField.snp.bottom).offset(4)
            $0.leading.equalTo(stepTextLabel)
            $0.height.equalTo(19)
        }
        phoneLabel.snp.makeConstraints {
            $0.top.equalTo(idtextField.snp.bottom).offset(64)
            $0.leading.equalTo(stepTextLabel)
        }
        phoneTextField.snp.makeConstraints {
            $0.top.equalTo(phoneLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-12)
            $0.height.equalTo(32)
        }
        sendButton.snp.makeConstraints {
            $0.top.equalTo(phoneLabel.snp.bottom).offset(8)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.width.equalTo(85)
            $0.height.equalTo(32)
        }
        helpLabel.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(8)
            $0.leading.equalTo(phoneTextField)
        }
        changeButton.snp.makeConstraints {
            $0.centerY.equalTo(helpLabel)
            $0.leading.equalTo(helpLabel.snp.trailing).offset(8)
            $0.width.equalTo(70)
            $0.height.equalTo(19)
        }
        phoneStateView.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(8)
            $0.leading.equalTo(stepTextLabel)
            $0.height.equalTo(19)
        }
        certNumberTextField.snp.makeConstraints {
            $0.top.equalTo(phoneStateView.snp.bottom).offset(8)
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-12)
            $0.height.equalTo(32)
        }
        remainTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(certNumberTextField)
            $0.trailing.equalTo(certNumberTextField.snp.trailing).offset(-4)
        }
        certNumberCheckButton.snp.makeConstraints {
            $0.top.equalTo(certNumberTextField)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.width.equalTo(85)
            $0.height.equalTo(32)
        }
        certNumberLoadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        certNumberStateView.snp.makeConstraints {
            $0.top.equalTo(certNumberCheckButton.snp.bottom).offset(4)
            $0.leading.equalTo(stepTextLabel)
            $0.height.equalTo(19)
        }
        saveButton.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.height.equalTo(48)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    private func setupComponents() {
        [idLabel, phoneLabel].forEach {
            $0.textColor = .black
            $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        }
        remainTimeLabel.font = UIFont.appFont(.pretendardMedium, size: 14)
        remainTimeLabel.textColor = UIColor.appColor(.neutral500)
        helpLabel.font = UIFont.appFont(.pretendardRegular, size: 12)
        helpLabel.textColor = UIColor.appColor(.neutral500)
        changeButton.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 12)
        changeButton.setTitleColor(UIColor.appColor(.new500), for: .normal)
    }
    private func setUpTextFieldUnderline() {
        [idtextField, phoneTextField, certNumberTextField].forEach {
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
