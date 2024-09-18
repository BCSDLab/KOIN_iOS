//
//  MyProfileViewController.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//


import Combine
import UIKit

final class MyProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MyProfileViewModel
    private let inputSubject: PassthroughSubject<MyProfileViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let infoLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then {
        $0.text = "기존정보"
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral600)
        $0.backgroundColor = UIColor.appColor(.neutral50)
    }
    
    private let idTitleLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then { label in
        label.text = "아이디"
    }
    
    private let idValueLabel = UILabel().then { label in
    }
    
    private let nameTitleLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then { label in
        label.text = "이름"
    }
    
    private let nameValueLabel = UILabel().then { label in
    }
    
    private let nicknameTitleLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then { label in
        label.text = "닉네임"
    }
    
    private let nicknameValueLabel = UILabel().then { label in
    }
    
    private let phoneTitleLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then { label in
        label.text = "휴대전화"
    }
    
    private let phoneValueLabel = UILabel().then { label in
    }
    
    private let stuentInfoLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then {
        $0.text = "학생정보"
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral600)
        $0.backgroundColor = UIColor.appColor(.neutral50)
    }
    
    private let studentNumberTitleLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then { label in
        label.text = "학번"
    }
    
    private let studentNumberValueLabel = UILabel().then { label in
    }
    
    private let majorTitleLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then { label in
        label.text = "전공"
    }
    
    private let majorValueLabel = UILabel().then { label in
    }
    
    private let genderTitleLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then { label in
        label.text = "성별"
    }
    
    private let genderValueLabel = UILabel().then { label in
    }
    
    private let revokeButton = UIButton().then { button in
        button.setTitle("회원탈퇴", for: .normal)
        button.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
    }
    
    private let revokeModalViewController = RevokeModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    // MARK: - Initialization
    
    init(viewModel: MyProfileViewModel) {
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
        revokeButton.addTarget(self, action: #selector(revokeButtonTapped), for: .touchUpInside)
        
        let editButton = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editButtonTapped))
            navigationItem.rightBarButtonItem = editButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.fetchUserData)
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .showToast(message, success):
                self?.showToast(message: message, success: success)
                self?.navigationController?.popViewController(animated: true)
            case let .showProfile(profile):
                self?.showProfile(profile)
            }
        }.store(in: &subscriptions)
        
        revokeModalViewController.revokeButtonPublisher.sink { [weak self] _ in
            self?.inputSubject.send(.revoke)
        }.store(in: &subscriptions)
    }
    
}

extension MyProfileViewController {
    
    @objc private func revokeButtonTapped() {
        present(revokeModalViewController, animated: true, completion: nil)
    }
    
    @objc private func editButtonTapped() {
        let modifyUseCase = DefaultModifyUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let fetchDeptListUseCase = DefaultFetchDeptListUseCase(timetableRepository: DefaultTimetableRepository(service: DefaultTimetableService()))
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let checkDuplicatedNicknameUseCase = DefaultCheckDuplicatedNicknameUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let viewController = ChangeMyProfileViewController(viewModel: ChangeMyProfileViewModel(modifyUseCase: modifyUseCase, fetchDeptListUseCase: fetchDeptListUseCase, fetchUserDataUseCase: fetchUserDataUseCase, checkDuplicatedNicknameUseCase: checkDuplicatedNicknameUseCase))
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showProfile(_ profile: UserDTO) {
        idValueLabel.text = profile.email
        nameValueLabel.text = profile.name
        nicknameValueLabel.text = profile.nickname
        phoneValueLabel.text = profile.phoneNumber
        studentNumberValueLabel.text = profile.studentNumber
        majorValueLabel.text = profile.major
        if let genderIntValue = profile.gender {
            if genderIntValue == 0 {
                genderValueLabel.text = "남성"
            } else {
                genderValueLabel.text = "여성"
            }
        }
    }
    
}

extension MyProfileViewController {
    
   
    private func setUpLayOuts() {
        [infoLabel, idTitleLabel, nameTitleLabel, nicknameTitleLabel, phoneTitleLabel, stuentInfoLabel, studentNumberTitleLabel, majorTitleLabel, idValueLabel, nameValueLabel, nicknameValueLabel, phoneValueLabel, studentNumberValueLabel, majorValueLabel, genderTitleLabel, genderValueLabel, revokeButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        idTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.height.equalTo(58)
        }
        idValueLabel.snp.makeConstraints { make in
            make.top.equalTo(idTitleLabel)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(58)
        }
        nameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(idTitleLabel.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.height.equalTo(58)
        }
        nameValueLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(58)
        }
        nicknameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.height.equalTo(58)
        }
        nicknameValueLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleLabel)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(58)
        }
        phoneTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitleLabel.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.height.equalTo(58)
        }
        phoneValueLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneTitleLabel)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(58)
        }
        stuentInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneTitleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        studentNumberTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(stuentInfoLabel.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.height.equalTo(58)
        }
        studentNumberValueLabel.snp.makeConstraints { make in
            make.top.equalTo(studentNumberTitleLabel)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(58)
        }
        majorTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(studentNumberTitleLabel.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.height.equalTo(58)
        }
        majorValueLabel.snp.makeConstraints { make in
            make.top.equalTo(majorTitleLabel)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(58)
        }
        genderTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(majorTitleLabel.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.height.equalTo(58)
        }
        genderValueLabel.snp.makeConstraints { make in
            make.top.equalTo(genderTitleLabel)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(58)
        }
        revokeButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.bottom.equalTo(view.snp.bottom).offset(-84)
            make.height.equalTo(48)
        }
    }
    
    private func setUpLabels() {
        [idTitleLabel, nameTitleLabel, nicknameTitleLabel, phoneTitleLabel, studentNumberTitleLabel, majorTitleLabel, genderTitleLabel].forEach { label in
            label.font = UIFont.appFont(.pretendardRegular, size: 16)
            label.textColor = UIColor.appColor(.neutral800)
        }
        [idValueLabel, nameValueLabel, nicknameValueLabel, phoneValueLabel, studentNumberValueLabel, majorValueLabel, genderValueLabel].forEach { label in
            label.font = UIFont.appFont(.pretendardRegular, size: 16)
            label.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpLabels()
        self.view.backgroundColor = .systemBackground
    }
}
