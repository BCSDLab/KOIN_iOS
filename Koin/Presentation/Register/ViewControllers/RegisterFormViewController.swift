//
//  RegisterFormViewController.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import Combine
import UIKit

final class RegisterFormViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    private let inputSubject: PassthroughSubject<RegisterViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    @Published private var currentStep: CurrentStep = .agreement
    private var userType: SelectTypeFormView.UserType? = nil

    enum CurrentStep: String, CaseIterable {
        case agreement = "약관 동의"
        case certification = "본인 인증"
        case selectType = "회원 유형 선택"
        case enterForm = "정보 입력"
        
        var number: Int {
            switch self {
            case .agreement: return 1
            case .certification: return 2
            case .selectType: return 3
            case .enterForm: return 4
            }
        }
        
        func next() -> CurrentStep? {
            let all = Self.allCases
            if let index = all.firstIndex(of: self), index + 1 < all.count {
                return all[index + 1]
            }
            return nil
        }
    }
    
    // MARK: - UI Components
    private let stepTextLabel = UILabel()
    
    private let stepLabel = UILabel()
    
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
    
    private lazy var agreementView = AgreementFormView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private lazy var certificationView = CertificationFormView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private lazy var selectTypeView = SelectTypeFormView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    private lazy var enterFormView = EnterFormView(viewModel: viewModel).then {
        $0.isHidden = true
    }
    
    // MARK: - Initialization
    init(viewModel: RegisterFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "회원가입"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
        
        certificationView.goToLoginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    private func bind() {
        $currentStep
            .receive(on: RunLoop.main)
            .sink { [weak self] step in
                guard let self = self else { return }
                let progress = Float(step.number) / Float(CurrentStep.allCases.count)
                self.progressView.setProgress(progress, animated: true)
                self.stepTextLabel.text = "\(step.number). \(step.rawValue)"
                self.stepLabel.text = "\(step.number) / \(CurrentStep.allCases.count)"
                
                switch step {
                case .agreement:
                    self.agreementView.isHidden = false
                case .certification:
                    self.agreementView.isHidden = true
                    self.certificationView.isHidden = false
                case .selectType:
                    self.certificationView.isHidden = true
                    self.selectTypeView.isHidden = false
                    self.nextButton.isHidden = true
                case .enterForm:
                    self.selectTypeView.isHidden = true
                    self.enterFormView.isHidden = false
                    self.enterFormView.configure(for: self.userType)
                    self.nextButton.isHidden = false
                }
            }.store(in: &subscriptions)
        
        agreementView.onRequiredAgreementsChanged = { [weak self] isEnabled in
            guard let self = self else { return }
            self.updateNextButtonState(enabled: isEnabled)
        }

        certificationView.onVerificationStatusChanged = { [weak self] isVerified in
            guard let self = self else { return }
            self.updateNextButtonState(enabled: isVerified)
        }

        selectTypeView.onUserTypeSelected = { [weak self] selectedType in
            guard let self = self else { return }
            self.userType = selectedType
            self.currentStep = .enterForm
        }
    }
    
    private func updateNextButtonState(enabled: Bool) {
        self.nextButton.isEnabled = enabled
        self.nextButton.backgroundColor = enabled ? UIColor.appColor(.primary500) : UIColor.appColor(.neutral300)
        self.nextButton.setTitleColor(enabled ? .white : UIColor.appColor(.neutral600), for: .normal)
    }
}

extension RegisterFormViewController {
    @objc private func loginButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func nextButtonTapped() {
        if currentStep == .selectType {
            return
        }
        
        if let nextStep = currentStep.next() {
            currentStep = nextStep
        }
        // TODO: 여기부분에 마지막 부분이면 추가 처리.
        // 학생, 외부인 분기 처리 추가 필요.
    }
}

extension RegisterFormViewController {
    private func setUpLayOuts() {
        [stepTextLabel, stepLabel, progressView, nextButton, agreementView, certificationView, selectTypeView, enterFormView].forEach {
            view.addSubview($0)
        }
    }

    
    private func setUpConstraints() {
        stepTextLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }
        
        stepLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        progressView.snp.makeConstraints {
            $0.top.equalTo(stepTextLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(3)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            $0.height.equalTo(50)
            $0.horizontalEdges.equalToSuperview().inset(32)
        }
        
        agreementView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(nextButton.snp.top).offset(-32)
        }

        certificationView.snp.makeConstraints {
            $0.edges.equalTo(agreementView)
        }

        selectTypeView.snp.makeConstraints {
            $0.edges.equalTo(agreementView)
        }

        enterFormView.snp.makeConstraints {
            $0.edges.equalTo(agreementView)
        }
    }
    
    private func setUpComponents() {
        [stepTextLabel, stepLabel].forEach {
            $0.textColor = UIColor.appColor(.primary500)
            $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpComponents()
        self.view.backgroundColor = .systemBackground
    }
}

