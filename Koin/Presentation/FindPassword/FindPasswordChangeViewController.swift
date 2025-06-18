//
//  FindPasswordChangeViewController.swift
//  koin
//
//  Created by 김나훈 on 6/19/25.
//

import Combine
import UIKit

final class FindPasswordChangeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FindPasswordViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let stepTextLabel = UILabel().then {
        $0.text = "2. 비밀번호 변경"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let stepLabel = UILabel().then {
        $0.text = "2 / 2"
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
    
    private let passwordLabel = UILabel().then {
        $0.text = "새 비밀번호"
    }
    
    private let passwordTextField = DefaultTextField(placeholder: "특수문자 포함 영어와 숫자 6 ~ 18자리", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14)).then {
        $0.isSecureTextEntry = true
    }
    
    private let passwordStateView = StateView().then {
        $0.isHidden = true
    }
    
    private let passwordCheckLabel = UILabel().then {
        $0.text = "비밀번호 확인"
    }
    
    private let passwordCheckTextField = DefaultTextField(placeholder: "비밀번호를 다시 입력해 주세요.", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14)).then {
        $0.isSecureTextEntry = true
    }
    
    private let passwordCheckStateView = StateView().then {
        $0.isHidden = true
    }
    
    private let nextButton = StateButton(font: UIFont.appFont(.pretendardMedium, size: 15)).then {
        $0.setTitle("다음", for: .normal)
        $0.setState(state: .unusable)
    }
    
    init(viewModel: FindPasswordViewModel) {
        self.viewModel = viewModel
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
        hideKeyboardWhenTappedAround()
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.toastMessagePublisher.sink { [weak self] message in
            self?.showToast(message: message)
        }.store(in: &subscriptions)
        
        viewModel.changeSuccessPublisher.sink { [weak self] in
            guard let self = self else { return }
            if var viewControllers = navigationController?.viewControllers {
                viewControllers.removeLast()
                let newVC = FindPasswordCertViewController(viewModel: viewModel, certType: .email)
                viewControllers.append(newVC)
                navigationController?.setViewControllers(viewControllers, animated: true)
            }
        }.store(in: &subscriptions)
        
        viewModel.passwordMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.passwordStateView.isHidden = false
            self?.passwordStateView.setState(state: response.1 ? .success : .warning, message: response.0)
        }.store(in: &subscriptions)
        
        viewModel.passwordMatchMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.passwordCheckStateView.isHidden = false
            self?.passwordCheckStateView.setState(state: response.1 ? .success : .warning, message: response.0)
        }.store(in: &subscriptions)
        
        viewModel.$isPasswordValidAll.receive(on: DispatchQueue.main).sink { [weak self] state in
            self?.nextButton.setState(state: state ? .usable : .unusable)
        }.store(in: &subscriptions)
    }
}

extension FindPasswordChangeViewController {
    @objc private func textFieldDidChange(textField: UITextField) {
        if textField == passwordTextField {
            viewModel.password = textField.text ?? ""
        } else if textField == passwordCheckTextField {
            viewModel.passwordMatch = textField.text ?? ""
        }
    }

}

extension FindPasswordChangeViewController {
    
    private func setupLayOuts() {
        [stepTextLabel, stepLabel, progressView, passwordLabel, passwordTextField, passwordStateView, passwordCheckLabel, passwordCheckTextField, passwordCheckStateView, nextButton].forEach {
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
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(64)
            $0.leading.equalTo(stepTextLabel)
        }
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.height.equalTo(32)
        }
        passwordStateView.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(4)
            $0.leading.equalTo(stepTextLabel)
            $0.height.equalTo(19)
        }
        passwordCheckLabel.snp.makeConstraints {
            $0.top.equalTo(passwordStateView.snp.bottom).offset(30)
            $0.leading.equalTo(stepTextLabel)
        }
        passwordCheckTextField.snp.makeConstraints {
            $0.top.equalTo(passwordCheckLabel.snp.bottom).offset(8)
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.height.equalTo(32)
        }
        passwordCheckStateView.snp.makeConstraints {
            $0.top.equalTo(passwordCheckTextField.snp.bottom).offset(4)
            $0.leading.equalTo(stepTextLabel)
            $0.height.equalTo(19)
        }
        nextButton.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.height.equalTo(48)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    private func setupComponents() {
        [passwordLabel, passwordCheckLabel].forEach {
            $0.textColor = .black
            $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
