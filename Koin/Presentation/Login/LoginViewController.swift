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
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.appImage(asset: .koinLogo)
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "KOREATECH 이메일"
        textField.autocapitalizationType = .none
        textField.font = UIFont.appFont(.pretendardRegular, size: 15)
        return textField
    }()
    
    private let emailGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "@ koreatech.ac.kr"
        label.font = UIFont.appFont(.pretendardRegular, size: 15)
        return label
    }()
    
    private let separateView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral500)
        return view
    }()
    
    private let emailWarningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 13)
        label.textColor = .red
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호"
        textField.font = UIFont.appFont(.pretendardRegular, size: 15)
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let separateView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral500)
        return view
    }()
    
    private let passwordWarningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 13)
        label.numberOfLines = 2
        label.textColor = .red
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.appColor(.sub500)
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 15)
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.appColor(.primary500)
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 15)
        return button
    }()
    
    private let findIdButton: UIButton = {
        let button = UIButton()
        button.setTitle("아이디 찾기", for: .normal)
        button.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 13)
        return button
    }()
    
    private let findPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("비밀번호 찾기", for: .normal)
        button.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 13)
        return button
    }()
    
    
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
        navigationController?.setNavigationBarHidden(false, animated: true)
        configureView()
        bind()
        hideKeyboardWhenTappedAround()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        findPasswordButton.addTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
        emailTextField.delegate = self
        passwordTextField.delegate = self
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
        emailWarningLabel.text = ""
        passwordWarningLabel.text = ""
        inputSubject.send(.login(emailTextField.text ?? "", passwordTextField.text ?? ""))
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
        [logoImageView, emailTextField, emailGuideLabel, separateView1, emailWarningLabel, passwordTextField, separateView2, passwordWarningLabel, loginButton, registerButton, findIdButton, findPasswordButton].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.height.equalTo(50)
            make.width.equalTo(80)
        }
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(70)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.centerX)
            make.height.equalTo(20)
        }
        emailGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.top)
            make.leading.equalTo(view.snp.centerX)
            make.height.equalTo(20)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
        }
        separateView1.snp.makeConstraints { make in
            make.top.equalTo(emailGuideLabel.snp.bottom).offset(5)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(1)
        }
        emailWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView1.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.height.equalTo(20)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailWarningLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(20)
        }
        separateView2.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(5)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(1)
        }
        passwordWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView2.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.greaterThanOrEqualTo(20)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordWarningLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(50)
        }
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(5)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(50)
        }
        findIdButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(10)
            make.trailing.equalTo(view.snp.centerX).offset(-5)
            make.width.equalTo(70)
            make.height.equalTo(15)
        }
        findPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(findIdButton.snp.top)
            make.leading.equalTo(view.snp.centerX)
            make.width.equalTo(90)
            make.height.equalTo(15)
        }
 
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}


