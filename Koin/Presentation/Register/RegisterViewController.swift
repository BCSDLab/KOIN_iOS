//
//  RegisterViewController.swift
//  koin
//
//  Created by 김나훈 on 3/18/24.
//


import Combine
import DropDown
import UIKit

final class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RegisterViewModel
    private let inputSubject: PassthroughSubject<RegisterViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let fakeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.appImage(asset: .koinLogo)
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.placeholder = "아우누리 아이디를 입력해주세요 (필수)"
        return textField
    }()
    
    private let emailGuideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 11)
        label.textColor = UIColor.appColor(.neutral500)
        label.text = "@koreatech.ac.kr은 입력하지 않으셔도 됩니다."
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호 (필수)"
        return textField
    }()
    
    private let passwordGuideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 11)
        label.textColor = UIColor.appColor(.neutral500)
        label.text = "비밀번호는 특수문자, 숫자를 포함해 6자 이내 18자 이하여야 합니다."
        label.numberOfLines = 0
        return label
    }()
    
    private let passwordConfirmTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호 확인 (필수)"
        return textField
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름 (선택)"
        return textField
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.isSelected = false
        textField.placeholder = "닉네임 (선택)"
        return textField
    }()
    
    private let checkButton: UIButton = {
        let button = UIButton()
        button.setTitle("중복확인", for: .normal)
        button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 13)
        button.backgroundColor = UIColor.appColor(.primary500)
        return button
    }()
    
    private let classNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "학번 (선택)"
        return textField
    }()
    
    private let phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.placeholder = "전화번호 (Ex.01012345678) (선택)"
        return textField
    }()
    
    private let deptButton: UIButton = {
       let button = UIButton()
        return button
    }()
    
    private let genderButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let genderDropDown: DropDown = {
       let dropDown = DropDown()
        dropDown.backgroundColor = .systemBackground
        return dropDown
    }()
    
    private let separateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral400)
        return view
    }()
    
    private let agreementCheckbox1: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.appImage(symbol: .square), for: .normal)
        button.tintColor = UIColor.appColor(.neutral500)
        return button
    }()
    
    private let agreementCheckbox2: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.appImage(symbol: .square), for: .normal)
        button.tintColor = UIColor.appColor(.neutral500)
        return button
    }()
    
    private let agreementCheckbox3: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.appImage(symbol: .square), for: .normal)
        button.tintColor = UIColor.appColor(.neutral500)
        return button
    }()
    
    private let agreementLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 12)
        label.text = "아래 이용약관에 모두 동의합니다."
        return label
    }()
    
    private let agreementLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 12)
        label.text = "개인정보 이용약관에 동의합니다."
        return label
    }()
    
    private let agreementLabel3: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 12)
        label.text = "코인 이용약관에 동의합니다."
        return label
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = UIColor.appColor(.primary500)
        button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
        return button
    }()
    
    private let agreementText1: UILabel = {
        let label = UILabel()
        label.text = "개인정보 이용약관"
        label.font = UIFont.appFont(.pretendardMedium, size: 15)
        return label
    }()
    
    private let agreementText2: UILabel = {
        let label = UILabel()
        label.text = "코인 이용약관"
        label.font = UIFont.appFont(.pretendardMedium, size: 15)
        return label
    }()
    
    private let agreementTextView1: UITextView = {
        let textView = UITextView()
        textView.text = AgreementText.personalInformation.description
        textView.textColor = UIColor.appColor(.neutral800)
        textView.font = UIFont.systemFont(ofSize: 13)
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return textView
    }()
    
    private let agreementTextView2: UITextView = {
        let textView = UITextView()
        textView.text = AgreementText.koin.description
        textView.textColor = UIColor.appColor(.neutral800)
        textView.font = UIFont.systemFont(ofSize: 13)
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return textView
    }()
    
    private let responseLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.appFont(.pretendardMedium, size: 13)
        return label
    }()
    
    private let deptDropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.backgroundColor = .systemBackground
        return dropDown
    }()
    
    // MARK: - Initialization
    
    init(viewModel: RegisterViewModel) {
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
        navigationItem.title = "회원가입"
        configureView()
        bind()
        inputSubject.send(.getDeptList)
        hideKeyboardWhenTappedAround()
        agreementCheckbox1.addTarget(self, action: #selector(allAgreementTapped), for: .touchUpInside)
        agreementCheckbox2.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementCheckbox3.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        
        nicknameTextField
            .addTarget(self, action: #selector(nicknameTextFieldDidChange), for: .editingChanged)
        checkButton.addTarget(self, action: #selector(checkButtonDidTapped(_:)), for: .touchUpInside)
        genderButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        deptButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .fill)
    }
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case let .showHttpResult(message, labelColor):
                self?.showHttpResult(message, labelColor)
            case .changeCheckButtonStatus:
                self?.checkButton.isSelected = true
            case .dissMissView:
                self?.dissMissView()
            case let .showDeptDropDownList(deptList):
                self?.setUpDropDown(dropDown: strongSelf.deptDropDown, button: strongSelf.deptButton, dataSource: deptList)
                self?.setUpDropDown(dropDown: strongSelf.genderDropDown, button: strongSelf.genderButton, dataSource: ["남", "여"])
            }
        }.store(in: &subscriptions)
        
    }
}

extension RegisterViewController {
    
    private func dissMissView() {
        let alertController = UIAlertController(title: "알림", message: "해당 이메일 주소로 인증 메일이 발송되었습니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func checkButtonDidTapped(_ button: UIButton) {
        let text = nicknameTextField.text ?? ""
        
        if text.isEmpty {
            responseLabel.text = "닉네임을 입력해 주세요"
            responseLabel.textColor = UIColor.appColor(.danger700)
        }
        else {
            inputSubject.send(.checkDuplicatedNickname(text))
        }
        
    }
    
    @objc private func nicknameTextFieldDidChange() {
        checkButton.isSelected = false
    }
    
    private func showHttpResult(_ message: String, _ color: SceneColorAsset) {
        responseLabel.text = message
        responseLabel.textColor = UIColor.appColor(color)
    }
    
    @objc private func registerButtonTapped() {
        responseLabel.text = ""
        for box in [agreementCheckbox1, agreementCheckbox2, agreementCheckbox3] {
            if !box.isSelected {
                responseLabel.text = "이용 약관들에 모두 동의해 주세요."
                responseLabel.textColor = UIColor.appColor(.danger700)
                return
            }
        }
        
        if !checkButton.isSelected && nicknameTextField.text != "" {
            responseLabel.text = "닉네임 중복 검사를 해주세요"
            responseLabel.textColor = UIColor.appColor(.danger700)
            return
        }
        
        let emailText: String
        if let text = emailTextField.text {
            emailText = "\(text)@koreatech.ac.kr"
        }
        else {
            emailText = ""
        }
        let passwordText = passwordTextField.text ?? ""
        let passwordConfirmText = passwordConfirmTextField.text ?? ""
        
        let nameText: String? = nameTextField.text?.count ?? 0 >= 1 ? nameTextField.text : nil
        let nicknameText: String? = nicknameTextField.text?.count ?? 0 >= 1 ? nicknameTextField.text : nil
        let phonetext: String? = phoneNumberTextField.text?.count ?? 0 >= 1 ? phoneNumberTextField.text : nil
        let studentNumberText: String? = classNumberTextField.text?.count ?? 0 >= 1 ? classNumberTextField.text : nil
        let genderStatus = genderButton.title(for: .normal)
        let genderText: Int? = genderStatus == "남" ? 0 : (genderStatus == "여" ? 1 : nil)
        var majorText: String?
        if let label = deptButton.subviews.compactMap({ $0 as? UILabel }).first {
            if label.text == "학부" {
                majorText = nil
            } else {
                majorText = label.text
            }
        }
        
        let registerRequest = UserRegisterRequest(email: emailText, gender: genderText, isGraduated: false, major: majorText, name: nameText, nickname: nicknameText, password: passwordText, phoneNumber: phonetext, studentNumber: studentNumberText)
        
        inputSubject.send(.tryRegister(registerRequest, passwordConfirmText))
        
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if sender == genderButton { genderDropDown.show() }
        else { deptDropDown.show() }
    }
    
    private func setUpDropDown(dropDown: DropDown, button: UIButton, dataSource: [String]) {
        dropDown.anchorView = button
        dropDown.bottomOffset = CGPoint(x: 0, y: button.bounds.height)
        dropDown.dataSource = dataSource
        dropDown.direction = .bottom
        dropDown.selectionAction = { (index: Int, item: String) in
        
            var buttonConfiguration = UIButton.Configuration.plain()
            buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0)
            
            var attributedTitle = AttributedString(item)
            attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 14)
            attributedTitle.foregroundColor = UIColor.appColor(.neutral800)
            buttonConfiguration.attributedTitle = attributedTitle
            button.configuration = buttonConfiguration

            if let imageView = button.subviews.compactMap({ $0 as? UIImageView }).first {
                imageView.image = UIImage.appImage(symbol: .chevronDown)
                NSLayoutConstraint.activate([
                    imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
                    imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
                ])
            }
        }
    }

    @objc private func allAgreementTapped() {
        agreementCheckbox1.isSelected = !agreementCheckbox1.isSelected
        let newState = agreementCheckbox1.isSelected
        
        updateCheckboxImage(checkbox: agreementCheckbox1, isSelected: newState)
        
        [agreementCheckbox2, agreementCheckbox3].forEach { checkbox in
            checkbox.isSelected = newState
            updateCheckboxImage(checkbox: checkbox, isSelected: newState)
        }
    }
    
    @objc private func individualAgreementTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        updateCheckboxImage(checkbox: sender, isSelected: sender.isSelected)
        
        let areBothSelected = agreementCheckbox2.isSelected && agreementCheckbox3.isSelected
        agreementCheckbox1.isSelected = areBothSelected
        updateCheckboxImage(checkbox: agreementCheckbox1, isSelected: areBothSelected)
    }
    
    private func updateCheckboxImage(checkbox: UIButton, isSelected: Bool) {
        if isSelected {
            checkbox.setImage(UIImage.appImage(symbol: .checkmarkSquare), for: .normal)
        } else {
            checkbox.setImage(UIImage.appImage(symbol: .square), for: .normal)
        }
    }
    
}

extension RegisterViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        [logoView, fakeLabel, emailTextField, emailGuideLabel, passwordTextField, passwordGuideLabel, passwordConfirmTextField, nameTextField, nicknameTextField, checkButton, classNumberTextField, phoneNumberTextField, deptButton, genderButton, separateView, agreementLabel1, agreementLabel2, agreementLabel3, agreementCheckbox1, agreementCheckbox2, agreementCheckbox3, registerButton,
         agreementTextView1, agreementTextView2, agreementText1, agreementText2, responseLabel].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
     
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
        fakeLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(1)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.width.equalTo(view.snp.width)
        }
        logoView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(70)
            make.centerX.equalTo(scrollView.snp.centerX)
            make.height.equalTo(70)
            make.width.equalTo(110)
        }
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(50)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(30)
        }
        emailGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(5)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailGuideLabel.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(30)
        }
        passwordGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(5)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
        }
        passwordConfirmTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordGuideLabel.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(30)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmTextField.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(30)
        }
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(checkButton.snp.leading).offset(-5)
            make.height.equalTo(30)
        }
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.top)
            make.trailing.equalTo(nameTextField.snp.trailing)
            make.height.equalTo(nameTextField.snp.height)
            make.width.equalTo(70)
        }
        classNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(30)
        }
        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(classNumberTextField.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(30)
        }
        deptButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.centerX).offset(-5)
            make.height.equalTo(30)
        }
        genderButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.centerX).offset(5)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(30)
        }
        responseLabel.snp.makeConstraints { make in
            make.top.equalTo(genderButton.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.greaterThanOrEqualTo(15)
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(responseLabel.snp.bottom).offset(20)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(1)
        }
        agreementCheckbox1.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(20)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        agreementCheckbox2.snp.makeConstraints { make in
            make.top.equalTo(agreementCheckbox1.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        agreementCheckbox3.snp.makeConstraints { make in
            make.top.equalTo(agreementCheckbox2.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        agreementLabel1.snp.makeConstraints { make in
            make.top.equalTo(agreementCheckbox1.snp.top)
            make.leading.equalTo(agreementCheckbox1.snp.trailing).offset(5)
        }
        agreementLabel2.snp.makeConstraints { make in
            make.top.equalTo(agreementCheckbox2.snp.top)
            make.leading.equalTo(agreementCheckbox3.snp.trailing).offset(5)
        }
        agreementLabel3.snp.makeConstraints { make in
            make.top.equalTo(agreementCheckbox3.snp.top)
            make.leading.equalTo(agreementCheckbox3.snp.trailing).offset(5)
        }
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(agreementLabel3.snp.bottom).offset(30)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(40)
        }
        agreementText1.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).offset(30)
        }
        agreementTextView1.snp.makeConstraints { make in
            make.top.equalTo(agreementText1.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(130)
        }
        agreementText2.snp.makeConstraints { make in
            make.top.equalTo(agreementTextView1.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).offset(30)
        }
        agreementTextView2.snp.makeConstraints { make in
            make.top.equalTo(agreementText2.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(130)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom).offset(-30)
        }

    }
    
    private func setUpTextFields() {
        [emailTextField, passwordTextField, passwordConfirmTextField, nameTextField, classNumberTextField, nicknameTextField, phoneNumberTextField].forEach { textField in
            textField.font = UIFont.appFont(.pretendardRegular, size: 13)
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            textField.layer.cornerRadius = 2.0
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
            textField.leftView = leftPaddingView
            textField.leftViewMode = .always
            textField.delegate = self
        }
        
    }
    
    private func setUpButtons() {
        [deptButton, genderButton].forEach { button in
            var buttonConfiguration = UIButton.Configuration.plain()
            buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0)
            var attributedTitle: AttributedString
            if button == genderButton { attributedTitle = "성별" }
            else { attributedTitle = "학부" }
           
            attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 14)
            attributedTitle.foregroundColor = UIColor.appColor(.neutral800)
            buttonConfiguration.attributedTitle = attributedTitle
            button.configuration = buttonConfiguration
            button.tintColor = UIColor.appColor(.neutral800)
            button.contentHorizontalAlignment = .leading
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            button.backgroundColor = UIColor.appColor(.neutral0)
            if let image = UIImage.appImage(symbol: .chevronDown) {
                let imageView = UIImageView(image: image)
                imageView.tintColor = UIColor.appColor(.neutral800)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                button.addSubview(imageView)
                NSLayoutConstraint.activate([
                    imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
                    imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
                ])
            }
        }
    
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpTextFields()
        setUpButtons()
        self.view.backgroundColor = .systemBackground
    }
}

