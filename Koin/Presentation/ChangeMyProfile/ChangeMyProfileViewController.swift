//
//  ChangeMyProfileViewController.swift
//  koin
//
//  Created by 김나훈 on 9/6/24.
//

import Combine
import DropDown
import UIKit

final class ChangeMyProfileViewController: UIViewController {
    
    private let viewModel: ChangeMyProfileViewModel
    private let inputSubject: PassthroughSubject<ChangeMyProfileViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    @Published private var remainTime = 180
    private var timer: AnyCancellable?
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then { scrollView in
    }
    
    private let deptButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private let deptDropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.backgroundColor = .systemBackground
        return dropDown
    }()
    
    private let primaryInfoLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then {
        $0.text = "기본정보"
        $0.backgroundColor = UIColor.appColor(.neutral50)
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral600)
    }
    
    private let idTitleLabel = UILabel().then {
        $0.text = "아이디"
    }
    
    private let idTextField = DefaultTextField(placeholder: "", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14)).then {
        $0.isUserInteractionEnabled = false
    }
    
    private let nameTitleLabel = UILabel().then {
        $0.text = "이름"
    }
    
    private let nameTextField = DefaultTextField(placeholder: "", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
    
    private let nicknameTitleLabel = UILabel().then {
        $0.text = "닉네임(선택)"
    }
    
    private let nicknameTextField = DefaultTextField(placeholder: "", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
    
    private let nicknameStateView = StateView().then {
        $0.isHidden = true
    }
    
    private let nicknameCheckButton = StateButton(title: "중복 확인").then {
        $0.setState(state: .unusable)
    }
    
    private let phoneTitleLabel = UILabel().then {
        $0.text = "휴대전화"
    }
    
    private let phoneTextField = DefaultTextField(placeholder: "", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
    
    private let sendButton = StateButton(title: "인증번호 발송").then {
        $0.setState(state: .unusable)
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
    
    private let helpLabel = UILabel().then {
        $0.text = "인증번호 발송이 안 되시나요?"
        $0.isHidden = true
    }
    
    private let inquryButton = UIButton().then {
        $0.setTitle("문의하기", for: .normal)
        $0.isHidden = true
    }
    
    private let certNumberStateView = StateView().then {
        $0.isHidden = true
    }
    
    private let emailTitleLabel = UILabel().then {
        $0.text = "이메일"
    }
    
    private let emailTextField = DefaultTextField(placeholder: "", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
    
    private let emailTextLabel = UILabel().then {
        $0.text = "@koreatech.ac.kr"
    }
    
    private let studentInfoLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then {
        $0.text = "학생정보"
        $0.backgroundColor = UIColor.appColor(.neutral50)
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral600)
    }
    
    private let studentNumberTitleLabel = UILabel().then {
        $0.text = "학번"
    }
    
    private let studentNumberTextField = DefaultTextField(placeholder: "", placeholderColor: UIColor.appColor(.neutral400), font: UIFont.appFont(.pretendardRegular, size: 14))
    
    private let majorTitleLabel = UILabel().then {
        $0.text = "전공"
    }
    
    private let majorButton = UIButton().then { button in
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
    }
    
    private let genderTitleLabel = UILabel().then {
        $0.text = "성별"
    }
    
    private let maleButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .systemBackground
        config.imagePadding = 4
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0)
        config.baseForegroundColor = UIColor.appColor(.neutral600)
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        button.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration ?? UIButton.Configuration.plain()
            let isSelected = button.isSelected
            updatedConfig.image = isSelected
            ? UIImage(named: "circleCheckedPrimary500")
            : UIImage(named: "circlePrimary500")
            var text = AttributedString("남성")
            text.font = UIFont.appFont(.pretendardRegular, size: 12)
            updatedConfig.attributedTitle = text
            button.configuration = updatedConfig
        }
        return button
    }()
    
    private let femaleButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .systemBackground
        config.imagePadding = 4
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0)
        config.baseForegroundColor = UIColor.appColor(.neutral600)
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        button.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration ?? UIButton.Configuration.plain()
            let isSelected = button.isSelected
            updatedConfig.image = isSelected
            ? UIImage(named: "circleCheckedPrimary500")
            : UIImage(named: "circlePrimary500")
            var text = AttributedString("여성")
            text.font = UIFont.appFont(.pretendardRegular, size: 12)
            updatedConfig.attributedTitle = text
            button.configuration = updatedConfig
        }
        return button
    }()
    
    private let saveButton = StateButton(font: UIFont.appFont(.pretendardMedium, size: 15)).then {
        $0.setTitle("저장", for: .normal)
        $0.setState(state: .unusable)
    }
    
    // MARK: - Initialization
    
    init(viewModel: ChangeMyProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "내 프로필"
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
        viewModel.fetchUserData()
        viewModel.fetchDeptList()
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        deptButton.addTarget(self, action: #selector(deptButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
        nicknameCheckButton.addTarget(self, action: #selector(nicknameCheckButtonTapped), for: .touchUpInside)
        inquryButton.addTarget(self, action: #selector(inquryButtonTapped), for: .touchUpInside)
        certNumberCheckButton.addTarget(self, action: #selector(certNumberCheckButtonTapped), for: .touchUpInside)
        
        nicknameTextField.addTarget(self, action: #selector(nicknameTextFieldDidChange(textField:)), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChange(textField:)), for: .editingChanged)
        certNumberTextField.addTarget(self, action: #selector(certNumberTextFieldDidChange), for: .editingChanged)
        hideKeyboardWhenTappedAround()
        [nameTextField, nicknameTextField, phoneTextField, studentNumberTextField].forEach {
            $0.delegate = self
        }
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
        
        viewModel.nicknameMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.nicknameStateView.isHidden = false
            self?.nicknameStateView.setState(state: response.1 ? .success : .warning, message: response.0)
        }.store(in: &subscriptions)
        
        viewModel.phoneNumberMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            guard let self = self else { return }
            phoneStateView.isHidden = false
            phoneStateView.setState(state: response.1 ? .success : .warning, message: response.0)
            if response.1 {
              startTimer()
                [certNumberTextField, remainTimeLabel, helpLabel, inquryButton, certNumberCheckButton].forEach {
                    $0.isHidden = false
                }
                emailTitleLabel.snp.remakeConstraints { [weak self] make in
                    guard let self = self else { return }
                    make.top.equalTo(helpLabel.snp.bottom).offset(32)
                    make.leading.equalTo(view.snp.leading).offset(24)
                }
            }
        }.store(in: &subscriptions)
        
        viewModel.certNumberMessagePublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.certNumberStateView.isHidden = false
            self?.certNumberStateView.setState(state: response.1 ? .success : .warning, message: response.0)
            if response.1 {
                self?.timer?.cancel()
                self?.timer = nil
                self?.remainTimeLabel.isHidden = true
            }
        }.store(in: &subscriptions)
        
        viewModel.$isFormValid.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] isValid in
            self?.saveButton.setState(state: isValid ? .usable : .unusable)
            if isValid {
                self?.saveButton.setTitle("저장", for: .normal)
            }
        }.store(in: &subscriptions)
        
        $remainTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] seconds in
                print(seconds)
                guard let self = self else { return }
                let minutes = seconds / 60
                let remainingSeconds = seconds % 60
                remainTimeLabel.text = String(format: "%02d:%02d", minutes, remainingSeconds)
                remainTimeLabel.isHidden = seconds == 0 || seconds == 180
                if seconds == 0 {
                    certNumberStateView.setState(state: .warning, message: "유효시간이 지났습니다. 인증번호를 재발송 해주세요.")
                    certNumberStateView.isHidden = false
                }
            }.store(in: &subscriptions)
        
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case let .showToast(message, success, request):
                switch request {
                case .nickname: break
                case .save:
                    if success { self?.navigationController?.popViewController(animated: true) }
                }
                self?.showToast(message: message, success: true)
            case let .showProfile(profile):
                self?.showProfile(profile)
            case let .showDeptDropDownList(deptList):
                self?.setUpDropDown(dropDown: strongSelf.deptDropDown, button: strongSelf.deptButton, dataSource: deptList)
            }
        }.store(in: &subscriptions)
        
    }
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
}

extension ChangeMyProfileViewController {
    @objc private func inquryButtonTapped() {
        if let url = URL(string:
                            "https://docs.google.com/forms/d/e/1FAIpQLSeRGc4IIHrsTqZsDLeX__lZ7A-acuioRbABZZFBDY9eMsMTxQ/viewform?usp=sf_link") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @objc private func sendButtonTapped() {
        viewModel.sendVerificationCode(phoneNumber: phoneTextField.text ?? "")
    }
    
    @objc private func nicknameCheckButtonTapped(_ sender: UIButton) {
        viewModel.checkDuplicatedNickname(nickname: nicknameTextField.text ?? "")
    }
    
    @objc private func certNumberCheckButtonTapped() {
        viewModel.checkVerificationCode(phoneNumber: phoneTextField.text ?? "", code: certNumberTextField.text ?? "")
    }
    
    @objc private func phoneNumberTextFieldDidChange(textField: UITextField) {
        saveButton.setState(state: .unusable)
        saveButton.setTitle("휴대전화 인증을 해주세요.", for: .normal)
        viewModel.phoneNumberSuccess = false
        if textField.text == "" { sendButton.setState(state: .unusable) }
        else {
            sendButton.setState(state: textField.text ?? "" == viewModel.userData?.phoneNumber ?? "" ? .unusable : .usable)
        }
    }
    
    @objc private func nicknameTextFieldDidChange(textField: UITextField) {
        saveButton.setState(state: .unusable)
        saveButton.setTitle("닉네임 중복확인을 해주세요.", for: .normal)
        viewModel.nicknameSuccess = false
        if textField.text == "" { nicknameCheckButton.setState(state: .unusable) }
        else {
            nicknameCheckButton.setState(state: textField.text ?? "" == viewModel.userData?.nickname ?? "" ? .unusable : .usable)
        }
    }
    @objc private func certNumberTextFieldDidChange(textField: UITextField) {
        if textField.text == "" { certNumberCheckButton.setState(state: .unusable) }
        else {
            certNumberCheckButton.setState(state: .usable)
        }
    }
    
    @objc private func genderButtonTapped(sender: UIButton) {
        let selectedButton: UIButton
        let unselectedButton: UIButton
        switch sender {
        case maleButton:
            selectedButton = maleButton
            unselectedButton = femaleButton
        default:
            selectedButton = femaleButton
            unselectedButton = maleButton
        }
        selectedButton.isSelected = true
        unselectedButton.isSelected = false
        viewModel.modifyUserData?.gender = selectedButton == maleButton ? 0 : 1
    }
    
    @objc private func deptButtonTapped() {
        deptDropDown.show()
    }
    
    @objc private func saveButtonTapped() {
        let nameText: String? = nameTextField.text?.count ?? 0 >= 1 ? nameTextField.text : nil
        let nicknameText: String? = nicknameTextField.text?.count ?? 0 >= 1 ? nicknameTextField.text : nil
        let phonetext: String? = phoneTextField.text?.count ?? 0 >= 1 ? phoneTextField.text : nil
        let studentNumberText: String? = studentNumberTextField.text?.count ?? 0 >= 1 ? studentNumberTextField.text : nil
        var deptText: String?
        if let label = deptButton.subviews.compactMap({ $0 as? UILabel }).first {
            if label.text == "선택된 전공이 없습니다." { deptText = nil }
            else { deptText = label.text }
        }
        let gender: Int?
        if maleButton.isSelected { gender = 0 }
        else if femaleButton.isSelected { gender = 1 }
        else { gender = nil }
        let userInfo = UserPutRequest(gender: gender, identity: 0, isGraduated: false, major: deptText, name: nameText, nickname: nicknameText, phoneNumber: phonetext, studentNumber: studentNumberText)
        inputSubject.send(.modifyProfile(userInfo))
    }
    
    private func showProfile(_ profile: UserDTO) {
        idTextField.text = profile.loginId
        nameTextField.text = profile.name
        nicknameTextField.text = profile.nickname
        phoneTextField.text = profile.phoneNumber
        studentNumberTextField.text = profile.studentNumber
        emailTextField.text = (profile.email ?? "").replacingOccurrences(of: "@koreatech.ac.kr", with: "", options: [.backwards, .anchored])
        if let major = profile.major {
            guard var buttonConfiguration = deptButton.configuration else { return }
            var attributedTitle = AttributedString(major)
            attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 16)
            attributedTitle.foregroundColor = UIColor.appColor(.neutral800)
            buttonConfiguration.attributedTitle = attributedTitle
            deptButton.configuration = buttonConfiguration
        }
        if let genderIntValue = profile.gender {
            if genderIntValue == 0 {
                maleButton.isSelected = true
            } else {
                femaleButton.isSelected = true
            }
        }
    }
    
    private func setUpDropDown(dropDown: DropDown, button: UIButton, dataSource: [String]) {
        dropDown.anchorView = button
        dropDown.bottomOffset = CGPoint(x: 0, y: button.bounds.height)
        dropDown.dataSource = dataSource
        dropDown.direction = .bottom
        dropDown.selectionBackgroundColor = .clear
        dropDown.selectionAction = { (index: Int, item: String) in
            var buttonConfiguration = UIButton.Configuration.plain()
            buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0)
            var attributedTitle = AttributedString(item)
            attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 16)
            attributedTitle.foregroundColor = UIColor.appColor(.neutral800)
            buttonConfiguration.attributedTitle = attributedTitle
            button.configuration = buttonConfiguration
        }
    }
    
}


extension ChangeMyProfileViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        view.addSubview(saveButton)
        [primaryInfoLabel, idTitleLabel, idTextField, nameTitleLabel, nameTextField, nicknameTitleLabel, nicknameTextField, phoneTitleLabel, phoneTextField, studentInfoLabel, studentNumberTitleLabel, studentNumberTextField, majorTitleLabel, deptButton, genderTitleLabel, maleButton, femaleButton, nicknameCheckButton , emailTitleLabel, emailTextField, emailTextLabel, sendButton, nicknameStateView, phoneStateView, certNumberStateView, certNumberTextField, remainTimeLabel, certNumberCheckButton, helpLabel, inquryButton].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).offset(-80)
        }
        primaryInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.equalTo(38)
        }
        idTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(primaryInfoLabel.snp.bottom).offset(5)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        idTextField.snp.makeConstraints { make in
            make.top.equalTo(idTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(32)
        }
        nameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom).offset(32)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(32)
        }
        nicknameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(32)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(nicknameCheckButton.snp.leading).offset(-12)
            make.height.equalTo(32)
        }
        nicknameStateView.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(5)
            $0.leading.equalTo(certNumberStateView)
            $0.height.equalTo(19)
        }
        nicknameCheckButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleLabel.snp.bottom).offset(8)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.width.equalTo(85)
            make.height.equalTo(32)
        }
        phoneTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(32)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(nicknameTextField)
            make.height.equalTo(32)
        }
        phoneStateView.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(5)
            $0.leading.equalTo(certNumberStateView)
            $0.height.equalTo(19)
        }
        certNumberTextField.snp.makeConstraints {
            $0.top.equalTo(phoneStateView.snp.bottom).offset(5)
            $0.leading.equalTo(phoneTextField)
            $0.trailing.equalTo(nicknameTextField)
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
        helpLabel.snp.makeConstraints {
            $0.top.equalTo(certNumberTextField.snp.bottom).offset(5)
            $0.leading.equalTo(certNumberTextField)
        }
        inquryButton.snp.makeConstraints {
            $0.centerY.equalTo(helpLabel)
            $0.leading.equalTo(helpLabel.snp.trailing).offset(8)
            $0.width.equalTo(50)
            $0.height.equalTo(19)
        }
        certNumberStateView.snp.makeConstraints {
            $0.top.equalTo(helpLabel.snp.bottom).offset(5)
            $0.leading.equalTo(phoneTitleLabel)
            $0.height.equalTo(19)
        }
        sendButton.snp.makeConstraints { make in
            make.centerY.equalTo(phoneTextField)
            make.trailing.equalTo(nicknameCheckButton)
            make.size.equalTo(nicknameCheckButton)
        }
        emailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(32)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.centerX)
            make.height.equalTo(32)
        }
        emailTextLabel.snp.makeConstraints { make in
            make.centerY.equalTo(emailTextField)
            make.leading.equalTo(emailTextField.snp.trailing).offset(8)
        }
        genderTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        maleButton.snp.makeConstraints { make in
            make.top.equalTo(genderTitleLabel.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.width.equalTo(100)
            make.height.equalTo(46)
        }
        femaleButton.snp.makeConstraints { make in
            make.top.equalTo(genderTitleLabel.snp.bottom).offset(16)
            make.leading.equalTo(maleButton.snp.trailing).offset(18.5)
            make.width.equalTo(100)
            make.height.equalTo(46)
        }
        studentInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(maleButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        studentNumberTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(studentInfoLabel.snp.bottom).offset(8)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        studentNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(studentNumberTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(32)
        }
        majorTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(studentNumberTextField.snp.bottom).offset(32)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        deptButton.snp.makeConstraints { make in
            make.top.equalTo(majorTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameTitleLabel.snp.leading)
            make.trailing.equalTo(studentNumberTextField)
            make.height.equalTo(46)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-400)
        }
        saveButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(48)
            make.bottom.equalTo(view.snp.bottom).offset(-24)
        }
    }
    
    private func setUpLabels() {
        [idTitleLabel, nameTitleLabel, nicknameTitleLabel, phoneTitleLabel, studentNumberTitleLabel, majorTitleLabel, emailTitleLabel].forEach {
            $0.font = UIFont.appFont(.pretendardRegular, size: 16)
            $0.textColor = UIColor.appColor(.neutral600)
        }
        remainTimeLabel.font = UIFont.appFont(.pretendardMedium, size: 14)
        remainTimeLabel.textColor = UIColor.appColor(.neutral500)
        helpLabel.font = UIFont.appFont(.pretendardRegular, size: 12)
        helpLabel.textColor = UIColor.appColor(.neutral500)
        inquryButton.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 12)
        inquryButton.setTitleColor(UIColor.appColor(.primary500), for: .normal)
        emailTextLabel.font = UIFont.appFont(.pretendardRegular, size: 14)
        emailTextLabel.textColor = .black
    }
    
    private func setUpButtons() {
        [deptButton].forEach { button in
            var buttonConfiguration = UIButton.Configuration.plain()
            buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
            var attributedTitle: AttributedString = "선택된 전공이 없습니다."
            attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 16)
            attributedTitle.foregroundColor = UIColor.appColor(.neutral800)
            buttonConfiguration.attributedTitle = attributedTitle
            button.configuration = buttonConfiguration
            button.tintColor = UIColor.appColor(.neutral800)
            button.contentHorizontalAlignment = .leading
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            button.backgroundColor = UIColor.appColor(.neutral0)
            if let image = UIImage.appImage(asset: .chevronUp) {
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
    private func setUpTextFieldUnderline() {
        [nameTextField, nicknameTextField, phoneTextField, studentNumberTextField, emailTextField, idTextField, certNumberTextField].forEach {
            $0.setUnderline(color: .appColor(.neutral300), thickness: 1, leftPadding: 0, rightPadding: 0)
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpButtons()
        setUpLabels()
        self.view.backgroundColor = .systemBackground
    }
}
