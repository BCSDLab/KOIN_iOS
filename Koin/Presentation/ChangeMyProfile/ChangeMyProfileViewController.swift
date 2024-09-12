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
    
    private let idValueLabel = UILabel().then { label in
    }
    
    private let nameTitleLabel = UILabel().then {
        $0.text = "이름"
    }
    
    private let nameTextField = UITextField().then { textField in
    }
    
    private let nicknameTitleLabel = UILabel().then {
        $0.text = "닉네임"
    }
    
    private let nicknameTextField = UITextField().then { textField in
    }
    
    private let phoneTitleLabel = UILabel().then {
        $0.text = "휴대전화"
    }
    
    private let phoneTextField = UITextField().then { textField in
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
    
    private let studentNumberTextField = UITextField().then { textField in
    }
    
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
    
    private let maleButton = UIButton().then { _ in
    }
    
    private let femaleButton = UIButton().then { _ in
    }
    
    private let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
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
        setUpButtonText(button: maleButton, text: "남성")
        setUpButtonText(button: femaleButton, text: "여성")
        inputSubject.send(.fetchUserData)
        inputSubject.send(.fetchDeptList)
        deptButton.addTarget(self, action: #selector(deptButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
        hideKeyboardWhenTappedAround()
        [nameTextField, nicknameTextField, phoneTextField, studentNumberTextField].forEach {
            $0.delegate = self
        }
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case let .showToast(message, success):
                self?.showToast(message: message, success: success)
                if success { self?.navigationController?.popViewController(animated: true) }
            case let .showProfile(profile):
                self?.showProfile(profile)
            case let .showDeptDropDownList(deptList):
                self?.setUpDropDown(dropDown: strongSelf.deptDropDown, button: strongSelf.deptButton, dataSource: deptList)
            }
        }.store(in: &subscriptions)
    }
}

extension ChangeMyProfileViewController {
    
    @objc private func genderButtonTapped(sender: UIButton) {
        switch sender {
        case maleButton: 
            maleButton.isSelected = true
            femaleButton.isSelected = false
        default:
            femaleButton.isSelected = true
            maleButton.isSelected = false
        }
        setUpButtonText(button: maleButton, text: "남성")
        setUpButtonText(button: femaleButton, text: "여성")
    }
    
    private func setUpButtonText(button: UIButton, text: String) {
        var configuration = UIButton.Configuration.plain()
        let imageSize = CGSize(width: 16, height: 16)
        let image = button.isSelected
        ? UIImage.appImage(asset: .filledCircle)
        : UIImage.appImage(asset: .circle)
        
        let resizedImage = image?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: imageSize.width, weight: .regular)
        )
        
        configuration.image = resizedImage
        var text = AttributedString(text)
        text.font = UIFont.appFont(.pretendardRegular, size: 16)
        configuration.attributedTitle = text
        configuration.imagePadding = 16
        configuration.baseBackgroundColor = .systemBackground
        configuration.baseForegroundColor = UIColor.appColor(.neutral800)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button.contentHorizontalAlignment = .leading
        button.configuration = configuration
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
            if label.text == "학부" { deptText = nil }
            else { deptText = label.text }
        }
        let gender: Int?
        if maleButton.isSelected { gender = 0 }
        else if femaleButton.isSelected { gender = 1 }
        else { gender = nil }
        let userInfo = UserPutRequest(gender: gender, identity: 0, isGraduated: false, major: deptText, name: nameText, nickname: nicknameText, password: nil, phoneNumber: phonetext, studentNumber: studentNumberText)
        inputSubject.send(.modifyProfile(userInfo))
    }
    
    private func showProfile(_ profile: UserDTO) {
        idValueLabel.text = profile.email
        nameTextField.text = profile.name
        nicknameTextField.text = profile.nickname
        phoneTextField.text = profile.phoneNumber
        studentNumberTextField.text = profile.studentNumber
        
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
                setUpButtonText(button: maleButton, text: "남성")
            } else {
                femaleButton.isSelected = true
                setUpButtonText(button: femaleButton, text: "여성")
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
        [primaryInfoLabel, idTitleLabel, idValueLabel, nameTitleLabel, nameTextField, nicknameTitleLabel, nicknameTextField, phoneTitleLabel, phoneTextField, studentInfoLabel, studentNumberTitleLabel, studentNumberTextField, majorTitleLabel, deptButton, genderTitleLabel, maleButton, femaleButton].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        idValueLabel.snp.makeConstraints { make in
            make.top.equalTo(idTitleLabel.snp.bottom).offset(18)
            make.leading.equalTo(40)
        }
        nameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(idValueLabel.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(40)
            make.trailing.equalTo(view.snp.trailing).offset(-40)
            make.height.equalTo(46)
        }
        nicknameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(5)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(40)
            make.trailing.equalTo(view.snp.trailing).offset(-40)
            make.height.equalTo(46)
        }
        phoneTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(40)
            make.trailing.equalTo(view.snp.trailing).offset(-40)
            make.height.equalTo(46)
        }
        studentInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        studentNumberTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(studentInfoLabel.snp.bottom).offset(8)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        studentNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(studentNumberTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(40)
            make.trailing.equalTo(view.snp.trailing).offset(-40)
            make.height.equalTo(46)
        }
        majorTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(studentNumberTextField.snp.bottom).offset(8)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        deptButton.snp.makeConstraints { make in
            make.top.equalTo(majorTitleLabel.snp.bottom).offset(5)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(46)
            make.width.equalTo(200)
        }
        genderTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(deptButton.snp.bottom).offset(30)
            make.leading.equalTo(nameTitleLabel.snp.leading)
        }
        maleButton.snp.makeConstraints { make in
            make.top.equalTo(genderTitleLabel.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading).offset(40)
            make.width.equalTo(70)
            make.height.equalTo(26)
        }
        femaleButton.snp.makeConstraints { make in
            make.top.equalTo(genderTitleLabel.snp.bottom).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-40)
            make.width.equalTo(70)
            make.height.equalTo(26)
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
        [idTitleLabel, nameTitleLabel, nicknameTitleLabel, phoneTitleLabel, studentNumberTitleLabel, majorTitleLabel].forEach {
            $0.font = UIFont.appFont(.pretendardRegular, size: 16)
            $0.textColor = UIColor.appColor(.neutral600)
        }
    }
    
    private func setUpTextFields() {
        [nameTextField, nicknameTextField, phoneTextField, studentNumberTextField].forEach {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 4
            $0.layer.masksToBounds = true
            
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: $0.frame.height))
            $0.leftView = paddingView
            $0.leftViewMode = .always
        }
    }
    
    private func setUpButtons() {
        [deptButton].forEach { button in
            var buttonConfiguration = UIButton.Configuration.plain()
            buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
            var attributedTitle: AttributedString = "학부"
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
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpLabels()
        setUpTextFields()
        setUpButtons()
        self.view.backgroundColor = .systemBackground
    }
}
