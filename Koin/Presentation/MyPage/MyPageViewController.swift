//
//  MyPageViewController.swift
//  koin
//
//  Created by 김나훈 on 3/19/24.
//


import Combine
import DropDown
import UIKit

final class MyPageViewController: UIViewController {
    
    private let viewModel: MyPageViewModel
    private let inputSubject: PassthroughSubject<MyPageViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.appImage(asset: .koinLogo)
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.0
        textField.isEnabled = false
        textField.textColor = UIColor.appColor(.neutral500)
        textField.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        textField.backgroundColor = UIColor.appColor(.neutral500).withAlphaComponent(0.3)
        textField.layer.cornerRadius = 2.0
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호 (필수)"
        return textField
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
    
    private let responseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 13)
        return label
    }()
    
    private let modifyButton: UIButton = {
        let button = UIButton()
        button.setTitle("정보수정", for: .normal)
        button.backgroundColor = UIColor.appColor(.primary500)
        button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
        return button
    }()
    
    private let revokeButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원탈퇴", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
        return button
    }()
    
    private let fakeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let guideLabel1: UILabel = {
        let label = UILabel()
        label.text = "계정명은 변경하실 수 없습니다."
        return label
    }()
    
    private let guideLabel2: UILabel = {
        let label = UILabel()
        label.text = "비밀번호는 특수문자, 숫자를 포함해 6자 이상 18자 이하여야 합니다."
        return label
    }()
    
    private let guideLabel3: UILabel = {
        let label = UILabel()
        label.text = "비밀번호를 입력하지 않으면 기존 비밀번호를 유지합니다."
        return label
    }()
    
    private let genderDropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.backgroundColor = .systemBackground
        return dropDown
    }()
    
    private let deptDropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.backgroundColor = .systemBackground
        return dropDown
    }()
    
    // MARK: - Initialization
    
    init(viewModel: MyPageViewModel) {
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
        bind()
        configureView()
        hideKeyboardWhenTappedAround()
        inputSubject.send(.getDeptList)
        inputSubject.send(.fetchUserData)
        genderButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        deptButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        modifyButton.addTarget(self, action: #selector(modifyButtonTapped), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        revokeButton.addTarget(self, action: #selector(revokeButtonTapped), for: .touchUpInside)
        nicknameTextField.addTarget(self, action: #selector(nicknameTextFieldDidChange), for: .editingChanged)
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case .modifySuccess:
                self?.dissMissView(text: "수정")
            case let .showHttpResult(message, labelColor):
                self?.responseLabel.text = message
                self?.responseLabel.textColor = UIColor.appColor(labelColor)
            case .loginAgain:
                self?.loginAgain()
            case .revokeSuccess:
                self?.dissMissView(text: "탈퇴")
            case .changeCheckButtonStatus:
                self?.checkButton.isSelected = true
            case let .showDeptDropDownList(deptList):
                strongSelf.setUpDropDown(dropDown: strongSelf.deptDropDown, button: strongSelf.deptButton, dataSource: deptList)
                strongSelf.setUpDropDown(dropDown: strongSelf.genderDropDown, button: strongSelf.genderButton, dataSource: ["남", "여"])
            case let .showUserProfile(userData):
                self?.showUserProfile(userData)
            }
        }.store(in: &subscriptions) 
    }
}

extension MyPageViewController {
    
    @objc private func revokeButtonTapped() {
        let alert = UIAlertController(title: "회원 탈퇴", message: "정말 탈퇴하시겠습니까?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "예", style: .destructive) { [weak self] _ in
            self?.inputSubject.send(.tryRevokeProfile)
        }
        
        let cancelAction = UIAlertAction(title: "아니오", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func loginAgain() {
        let alert = UIAlertController(title: "세션 만료", message: "세션이 만료되었습니다. 다시 로그인해주세요.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func checkButtonTapped() {
        let text = nicknameTextField.text ?? ""
        
        if text.isEmpty {
            responseLabel.text = "닉네임을 입력해 주세요"
            responseLabel.textColor = UIColor.appColor(.danger700)
        }
        else {
            inputSubject.send(.checkNickname(text))
        }
    }
    
    private func dissMissView(text: String) {
        let guideText = text == "수정" ? "수정이" : "탈퇴가"
        let alert = UIAlertController(title: "\(text) 완료", message: "회원 정보 \(guideText) 완료되었습니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func nicknameTextFieldDidChange() {
        checkButton.isSelected = false
    }
    
    @objc private func modifyButtonTapped() {
        responseLabel.text = ""
        if !checkButton.isSelected && nicknameTextField.text != "" {
            responseLabel.text = "닉네임 중복 검사를 해주세요"
            responseLabel.textColor = UIColor.appColor(.danger700)
            return
        }
        
        let passwordText = passwordTextField.text ?? ""
        let passwordConfirmText = passwordConfirmTextField.text ?? ""
        let nameText: String? = nameTextField.text?.count ?? 0 >= 1 ? nameTextField.text : nil
        let nicknameText: String? = nicknameTextField.text?.count ?? 0 >= 1 ? nicknameTextField.text : nil
        let phonetext: String? = phoneNumberTextField.text?.count ?? 0 >= 1 ? phoneNumberTextField.text : nil
        let studentNumberText: String? = classNumberTextField.text?.count ?? 0 >= 1 ? classNumberTextField.text : nil
        var deptText: String?
        if let label = deptButton.subviews.compactMap({ $0 as? UILabel }).first {
            if label.text == "학부" { deptText = nil}
            else { deptText = label.text }
        }
        var genderText: Int?
        if let label = genderButton.subviews.compactMap({ $0 as? UILabel }).first {
            genderText = label.text == "남" ? 0 : label.text == "여" ? 1 : nil
        }
        
        let userInfo = UserPutRequest(gender: genderText, identity: 0, isGraduated: false, major: deptText, name: nameText, nickname: nicknameText, password: passwordText, phoneNumber: phonetext, studentNumber: studentNumberText)
        inputSubject.send(.tryModifyProfile(userInfo, passwordConfirmText))
    }
    
    private func showUserProfile(_ data: UserDTO) {

        emailTextField.text = data.email
        nameTextField.text = data.name
        nicknameTextField.text = data.nickname
        classNumberTextField.text = data.studentNumber
        phoneNumberTextField.text = data.phoneNumber
        if let gender = data.gender {
            let genderTitle = gender == 0 ? "남" : gender == 1 ? "여" : "성별"
            updateButtonTitle(button: genderButton, title: genderTitle)
        } else { updateButtonTitle(button: genderButton, title: "성별") }
        if let dept = data.major {
            updateButtonTitle(button: deptButton, title: dept)
        }
        classNumberTextField.sendActions(for: .editingChanged)
        checkButton.isSelected = true
    }
    
    private func updateButtonTitle(button: UIButton, title: String) {
        guard var buttonConfiguration = button.configuration else { return }
        var attributedTitle = AttributedString(title)
        attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 14)
        attributedTitle.foregroundColor = UIColor.appColor(.neutral800)
        buttonConfiguration.attributedTitle = attributedTitle
        
        button.configuration = buttonConfiguration
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
    
    @objc func buttonTapped(_ sender: UIButton) {
        if sender == genderButton { genderDropDown.show() }
        else { deptDropDown.show() }
    }
    
}


extension MyPageViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        [fakeLabel,logoView, emailTextField, passwordTextField, passwordConfirmTextField, nameTextField, nicknameTextField, classNumberTextField, phoneNumberTextField, checkButton, deptButton, genderButton, modifyButton, revokeButton, guideLabel1, guideLabel2, guideLabel3, responseLabel].forEach {
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
        guideLabel1.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(5)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(guideLabel1.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(30)
        }
        guideLabel2.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(5)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
        }
        passwordConfirmTextField.snp.makeConstraints { make in
            make.top.equalTo(guideLabel2.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(30)
        }
        guideLabel3.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmTextField.snp.bottom).offset(5)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(guideLabel3.snp.bottom).offset(10)
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
        genderButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.centerX).offset(5)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
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
            make.height.equalTo(20)
        }
        modifyButton.snp.makeConstraints { make in
            make.top.equalTo(responseLabel.snp.bottom).offset(30)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(40)
        }
        revokeButton.snp.makeConstraints { make in
            make.top.equalTo(modifyButton.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading).offset(30)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-30)
            make.height.equalTo(40)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom).offset(-200)
        }
    }
    
    private func setUpViewDetail() {
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
        [guideLabel1, guideLabel2, guideLabel3].forEach { label in
            label.font = UIFont.appFont(.pretendardRegular, size: 11)
            label.textColor = UIColor.appColor(.neutral500)
            label.numberOfLines = 0
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
        setUpViewDetail()
        setUpButtons()
        self.view.backgroundColor = .systemBackground
    }
}
