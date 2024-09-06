//
//  ChangePasswordViewController.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import Combine
import UIKit

final class ChangePasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ChangePasswordViewModel
    private let inputSubject: PassthroughSubject<ChangePasswordViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let progressTitleLabel = UILabel().then {
        $0.text = "1. 계정 인증"
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = UIColor.appColor(.primary500)
    }
    
    private let progressStepLabel = UILabel().then {
        $0.text = "1 / 2"
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = UIColor.appColor(.primary500)
    }
    
    private let progressView = UIProgressView().then {
        $0.trackTintColor = UIColor.appColor(.neutral300)
        $0.progressTintColor = UIColor.appColor(.primary500)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.progress = 0.5
        $0.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               $0.heightAnchor.constraint(equalToConstant: 3)
           ])
    }
    
    private let completeButton = UIButton().then { button in
        button.setTitle("다음", for: .normal)
        button.backgroundColor = UIColor.appColor(.neutral300)
        button.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
    }
    
    private let certificationView = CertificationView(frame: .zero).then { view in
    }
    
    private lazy var changePasswordView = ChangePasswordView(frame: .zero, viewModel: viewModel).then { view in
        view.isHidden = true
    }
    
    // MARK: - Initialization
    
    init(viewModel: ChangePasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "비밀번호 변경"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureView()
        inputSubject.send(.fetchUserData)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .showToast(message, success):
                self?.showToast(message: message, success: success)
                if success {
                    self?.navigationController?.popViewController(animated: true)
                }
            case let .showEmail(email):
                self?.certificationView.fillEmailText(text: email)
            case .passNextStep:
                self?.passNextStep()
            case let .showErrorMessage(message):
                self?.showErrorMessage(message: message)
            case let .updateButtonEnable(isEnable):
                self?.changeButtonEnable(isEnable: isEnable)
            }
        }.store(in: &subscriptions)
        
        certificationView.passwordEmptyCheckPublisher.sink { [weak self] isEmpty in
            self?.changeButtonEnable(isEnable: !isEmpty)
        }.store(in: &subscriptions)
    }
    
}

extension ChangePasswordViewController {
    
    private func changeButtonEnable(isEnable: Bool) {
        completeButton.backgroundColor = isEnable ? UIColor.appColor(.primary500) : UIColor.appColor(.neutral300)
        completeButton.setTitleColor(isEnable ? UIColor.appColor(.neutral0) : UIColor.appColor(.neutral600), for: .normal)
        completeButton.isEnabled = isEnable ? true : false
    }
    
    private func showErrorMessage(message: String) {
        if !certificationView.isHidden {
            certificationView.showErrorMessage(message: message)
        }
    }
    
    private func passNextStep() {
        progressTitleLabel.text = "2. 비밀번호 변경"
        progressStepLabel.text = "2 / 2"
        progressView.progress = 1.0
        completeButton.setTitle("완료", for: .normal)
        certificationView.isHidden = true
        changePasswordView.isHidden = false
        completeButton.backgroundColor = UIColor.appColor(.neutral300)
        completeButton.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        completeButton.isEnabled = false
    }
    
    @objc private func completeButtonTapped() {
        switch viewModel.currentStep {
        case 1: inputSubject.send(.checkPassword(certificationView.getPasswordText()))
        default: inputSubject.send(.changePassword(changePasswordView.getPasswordText()))
        }
    }
    
}

extension ChangePasswordViewController {
    
    private func setUpLayOuts() {
        [progressTitleLabel, progressStepLabel, progressView, certificationView, changePasswordView, completeButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        progressTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        progressStepLabel.snp.makeConstraints { make in
            make.top.equalTo(progressTitleLabel.snp.top)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
        }
        progressView.snp.makeConstraints { make in
            make.top.equalTo(progressTitleLabel.snp.bottom).offset(10)
            make.leading.equalTo(progressTitleLabel.snp.leading)
            make.trailing.equalTo(progressStepLabel.snp.trailing)
            make.height.equalTo(3)
        }
        certificationView.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(28)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(200)
        }
        changePasswordView.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(28)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(300)
        }
        completeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-24)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
