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
    @Published private var remainTime = 300
    private var timer: AnyCancellable?
    
    // MARK: - UI Components
    
    private lazy var phoneNumberLabel = UILabel().then {
        $0.text = certType == .phone ? "휴대전화 번호" : "이메일"
    }
    
    private lazy var phoneNumberTextField = DefaultTextField(placeholder: certType == .phone ? "- 없이 번호를 입력해 주세요." : "등록된 이메일을 입력해 주세요.", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
    
    private let sendButton = StateButton().then {
        $0.setState(state: .unusable)
        $0.setTitle("인증번호 발송", for: .normal)
    }
    
    private let helpLabel = UILabel().then {
        $0.text = "휴대전화 등록을 안 하셨나요?"
    }
    
    private let changeButton = UIButton().then {
        $0.setTitle("이메일로 받기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.primary500), for: .normal)
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
    
    private let certNumberStateView = StateView()
    
    private let saveButton = StateButton(font: UIFont.appFont(.pretendardMedium, size: 16)).then {
        $0.setState(state: .unusable)
        $0.setTitle("저장", for: .normal)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpTextFieldUnderline()
    }
    
    // MARK: - Bind
    
    private func bind() {
        $remainTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] seconds in
                print(seconds)
                guard let self = self else { return }
                let minutes = seconds / 60
                let remainingSeconds = seconds % 60
                remainTimeLabel.text = String(format: "%02d:%02d", minutes, remainingSeconds)
                remainTimeLabel.isHidden = seconds == 0 || seconds == 300
                if seconds == 0 {
                    certNumberStateView.setState(state: .warning, message: "유효시간이 지났습니다. 인증번호를 재발송 해주세요.")
                    certNumberStateView.isHidden = false
                }
            }.store(in: &subscriptions)
        
        viewModel.sendMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.phoneStateView.setState(state: response.1 ? .success : .warning , message: response.0)
            self?.phoneStateView.isHidden = false
            if response.1 {
                self?.startTimer()
            }
            self?.certNumberStateView.isHidden = true
        }.store(in: &subscriptions)
        
        viewModel.checkMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.certNumberStateView.isHidden = false
            if !response.1 {
                self?.certNumberStateView.setState(state: .warning, message: response.0)
            } else {
                self?.certNumberStateView.setState(state: .success, message: response.0)
                self?.saveButton.setState(state: .usable)
                self?.certNumberButton.setState(state: .unusable)
                self?.timer?.cancel()
                self?.timer = nil
                self?.remainTimeLabel.isHidden = true
            }
        }.store(in: &subscriptions)
    }
}

extension FindPhoneIdViewController {
    private func startTimer() {
        remainTime = 300
        timer?.cancel()
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainTime > 0 {
                    self.remainTime -= 1
                } else {
                    self.timer?.cancel()
                }
            }
    }
    @objc private func sendButtonTapped() {
        if certType == .phone {
            viewModel.sendVerificationCode(phoneNumber: phoneNumberTextField.text ?? "")
        } else {
            viewModel.sendVerificationEmail(email: phoneNumberTextField.text ?? "")
        }
    }
    @objc private func certNumberButtonTapped() {
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
            if textField.text == "" {
                sendButton.setState(state: .unusable)
            } else {
                sendButton.setState(state: .usable)
            }
        } else {
            if textField.text == "" {
                certNumberButton.setState(state: .unusable)
            } else {
                certNumberButton.setState(state: .usable)
            }
        }
    }
}

extension FindPhoneIdViewController {
    
    private func setupLayOuts() {
        [phoneNumberLabel, phoneNumberTextField, sendButton, helpLabel, changeButton, phoneStateView, remainCountLabel, certNumberTextField, remainTimeLabel, certNumberButton, certNumberStateView, saveButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        phoneNumberLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
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
            $0.height.equalTo(19)
        }
        helpLabel.snp.makeConstraints {
            $0.top.equalTo(phoneStateView.snp.bottom).offset(5)
            $0.leading.equalTo(phoneNumberLabel)
        }
        changeButton.snp.makeConstraints {
            $0.leading.equalTo(helpLabel.snp.trailing).offset(5)
            $0.top.bottom.equalTo(helpLabel)
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
