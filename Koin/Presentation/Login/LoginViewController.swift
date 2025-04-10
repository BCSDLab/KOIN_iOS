//
//  LoginViewController.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Combine
import SafariServices
import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: LoginViewModel
    private let inputSubject: PassthroughSubject<LoginViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let logoImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .koinLogo)
    }
    
    private let idTextField = UITextField().then {
        $0.placeholder = "아이디(Koreatech ID/전화번호)"
        $0.autocapitalizationType = .none
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
    }
    
    private let separateView1 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let idWarningLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 13)
        $0.textColor = UIColor.appColor(.sub500)
    }
    
    private let passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호"
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
        $0.isSecureTextEntry = true
    }
    
    private let changeSecureButton = UIButton().then { button in
        button.setImage(UIImage.appImage(asset: .visibility), for: .normal)
    }
    
    private let separateView2 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let passwordWarningLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 13)
        $0.numberOfLines = 2
        $0.textColor = UIColor.appColor(.sub500)
    }
    
    private let loginButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.sub500)
        $0.setTitle("로그인", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.layer.cornerRadius = 8
    }
    
    private let registerButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.layer.cornerRadius = 8
    }
    
    private let findIdButton = UIButton().then {
        $0.setTitle("아이디 찾기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 13)
    }
    
    private let findPasswordButton = UIButton().then {
        $0.setTitle("비밀번호 찾기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 13)
    }
    
    
    // MARK: - Initialization
    init(viewModel: LoginViewModel) {
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
        navigationItem.title = "로그인"
        configureView()
        bind()
        hideKeyboardWhenTappedAround()
        changeSecureButton.addTarget(self, action: #selector(changeSecureButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        findPasswordButton.addTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
        idTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .fill)
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .showErrorMessage(message):
                self?.passwordWarningLabel.text = message
            case .loginSuccess:
                self?.navigationController?.popViewController(animated: true)
            }
        }.store(in: &subscriptions)
        
    }
}

extension LoginViewController {
    @objc private func changeSecureButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        changeSecureButton.setImage(passwordTextField.isSecureTextEntry ? UIImage.appImage(asset: .visibility) : UIImage.appImage(asset: .visibilityNon), for: .normal)
    }

    @objc private func findIdButtonTapped() {
        if let url = URL(string: "https://portal.koreatech.ac.kr/kut/page/findUser.jsp") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
        }
    }
    
    @objc private func findPasswordButtonTapped() {
        let findPasswordViewController = FindPasswordViewController(viewModel: FindPasswordViewModel(findPasswordUseCase: DefaultFindPasswordUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))))
        findPasswordViewController.title = "비밀번호 찾기"
        navigationController?.pushViewController(findPasswordViewController, animated: true)
    }
    
    
    @objc func loginButtonTapped() {
        idWarningLabel.text = ""
        passwordWarningLabel.text = ""
        inputSubject.send(.login(idTextField.text ?? "", passwordTextField.text ?? ""))
    }
    
    @objc func registerButtonTapped() {
        let timetableRepositoy = DefaultTimetableRepository(service: DefaultTimetableService())
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let logRepoository = GA4AnalyticsRepository(service: GA4AnalyticsService())
        let registerViewController = RegisterViewController(viewModel: RegisterViewModel(fetchDeptListUseCase: DefaultFetchDeptListUseCase(timetableRepository: timetableRepositoy), registerUseCase: DefaultRegisterUseCase(userRepository: userRepository), checkDuplicatedNicknameUseCase: DefaultCheckDuplicatedNicknameUseCase(userRepository: userRepository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: logRepoository)))
        registerViewController.title = "회원가입"
        navigationController?.pushViewController(registerViewController, animated: true)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.User.startSignUp, .click, "회원가입 시작"))
    }
}

extension LoginViewController {
    
    private func setUpLayOuts() {
        [logoImageView, idTextField, separateView1, idWarningLabel, passwordTextField, changeSecureButton, separateView2, passwordWarningLabel, loginButton, registerButton, findIdButton, findPasswordButton].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(110)
            make.leading.equalTo(view.snp.leading).offset(40)
            make.height.equalTo(60)
            make.width.equalTo(107)
        }
        idTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(32)
            make.leading.equalTo(view.snp.leading).offset(48)
            make.trailing.equalTo(view.snp.trailing).offset(-48)
            make.height.equalTo(40)
        }
        separateView1.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom)
            make.leading.equalTo(idTextField.snp.leading)
            make.trailing.equalTo(idTextField.snp.trailing)
            make.height.equalTo(1)
        }
        idWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView1.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.height.equalTo(20)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom).offset(16)
            make.leading.equalTo(idTextField.snp.leading)
            make.trailing.equalTo(idTextField.snp.trailing)
            make.height.equalTo(40)
        }
        changeSecureButton.snp.makeConstraints { make in
            make.centerY.equalTo(passwordTextField.snp.centerY)
            make.trailing.equalTo(passwordTextField.snp.trailing)
            make.width.height.equalTo(20)
        }
        separateView2.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom)
            make.leading.equalTo(passwordTextField.snp.leading)
            make.trailing.equalTo(passwordTextField.snp.trailing)
            make.height.equalTo(1)
        }
        passwordWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView2.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.greaterThanOrEqualTo(20)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(separateView2.snp.bottom).offset(48)
            make.leading.equalTo(separateView2.snp.leading)
            make.trailing.equalTo(separateView2.snp.trailing)
            make.height.equalTo(44)
        }
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(24)
            make.leading.equalTo(loginButton.snp.leading)
            make.trailing.equalTo(loginButton.snp.trailing)
            make.height.equalTo(44)
        }
        findIdButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(33)
            make.leading.equalTo(registerButton.snp.leading).offset(8)
            make.width.equalTo(84)
            make.height.equalTo(20)
        }
        findPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(findIdButton.snp.top)
            make.leading.equalTo(findIdButton.snp.trailing).offset(14)
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}


