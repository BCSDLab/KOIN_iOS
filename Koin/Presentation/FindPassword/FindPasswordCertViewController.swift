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
    @Published private var remainTime = 180
    private var timer: AnyCancellable?
    
    // MARK: - UI Components
    
    private let stepTextLabel = UILabel().then {
        $0.text = "1. 계정 인증"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let stepLabel = UILabel().then {
        $0.text = "1 / 2"
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
            self?.sendButton.setState(state: text.isEmpty ? .unusable : .usable)
        }.store(in: &subscriptions)
        
        viewModel.$certNumber.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] text in
            self?.certNumberCheckButton.setState(state: text.isEmpty ? .unusable : .usable)
        }.store(in: &subscriptions)
        
        viewModel.sendMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self = self else { return }
            phoneStateView.isHidden = false
            phoneStateView.setState(state: response.1 ? .success : .warning, message: response.0)
            if response.1 {
                startTimer()
                [certNumberTextField, remainTimeLabel, helpLabel, changeButton, certNumberCheckButton].forEach {
                    $0.isHidden = false
                }
            }
        }.store(in: &subscriptions)
        
        viewModel.checkMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self = self else { return }
            certNumberStateView.isHidden = false
            certNumberStateView.setState(state: response.1 ? .success : .warning, message: response.0)
            if response.1 {
                saveButton.setState(state: .usable)
                timer?.cancel()
                timer = nil
                remainTimeLabel.isHidden = true
            }
        }.store(in: &subscriptions)
    }
}

extension FindPasswordCertViewController {
    private func startTimer() {
        remainTime = 180
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
        switch certType {
        case .phone: viewModel.sendVerificationCode()
        case .email: viewModel.sendVerificationEmail()
        }
    }
    @objc private func saveButtonTapped() {
        navigationController?.pushViewController(FindPasswordChangeViewController(viewModel: viewModel), animated: true)
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
        case .phone: viewModel.checkVerificationCode()
        case .email: viewModel.checkVerificationEmail()
        }
    }
    @objc private func textFieldDidChange(textField: UITextField) {
        if textField == phoneTextField {
            viewModel.inputData = textField.text ?? ""
        } else if textField == certNumberTextField {
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
            $0.top.equalTo(phoneTextField.snp.bottom).offset(3)
            $0.leading.equalTo(phoneTextField)
        }
        changeButton.snp.makeConstraints {
            $0.centerY.equalTo(helpLabel)
            $0.leading.equalTo(helpLabel.snp.trailing).offset(8)
            $0.width.equalTo(70)
            $0.height.equalTo(19)
        }
        phoneStateView.snp.makeConstraints {
            $0.top.equalTo(helpLabel.snp.bottom).offset(4)
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
        changeButton.setTitleColor(UIColor.appColor(.primary500), for: .normal)
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
