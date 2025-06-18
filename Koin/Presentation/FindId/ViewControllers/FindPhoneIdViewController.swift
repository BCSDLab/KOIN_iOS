//
//  FindPhoneIdViewController.swift
//  koin
//
//  Created by 김나훈 on 6/17/25.
//

import Combine
import UIKit

final class FindPhoneIdViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FindIdViewModel
    private var subscriptions: Set<AnyCancellable> = []
    @Published private var remainCount = 5
    @Published private var remainTime = 300
    
    
    // MARK: - UI Components

    private let phoneNumberLabel = UILabel().then {
        $0.text = "휴대전화 번호"
    }
    
    private let phoneNumberTextField = DefaultTextField(placeholder: "- 없이 번호를 입력해 주세요.", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14)).then {
        $0.keyboardType = .numberPad
    }
    
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
    }
    
    init(viewModel: FindIdViewModel) {
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
        setupUI()
        bind()
        hideKeyboardWhenTappedAround()
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        certNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    // MARK: - Bind
    
    private func bind() {
        $remainCount.receive(on: DispatchQueue.main).sink { [weak self] count in
            //
        }.store(in: &subscriptions)
    }
}

extension FindPhoneIdViewController {
    
    @objc private func sendButtonTapped() {
        
    }
    @objc private func certNumberButtonTapped() {
        
    }
    @objc private func changeButtonTapped() {
        
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
            $0.trailing.equalTo(certNumberTextField.snp.trailing).offset(-28)
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
