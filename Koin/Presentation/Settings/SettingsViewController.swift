//
//  SettingsViewController.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import Combine
import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: SettingsViewModel
    private let inputSubject: PassthroughSubject<SettingsViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let generalLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then {
        $0.text = "일반"
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral600)
        $0.backgroundColor = UIColor.appColor(.neutral50)
    }
    
    private let profileButton = UIButton().then { label in
    }
    
    private let changePasswordButton = UIButton().then { button in
    }
    
    private let notiButton = UIButton().then { button in
    }
    
    private let serviceLabel = InsetLabel(top: 0, left: 24, bottom: 0, right: 0).then {
        $0.text = "서비스"
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral600)
        $0.backgroundColor = UIColor.appColor(.neutral50)
    }
    
    private let personalPolicyButton = UIButton().then { button in
    }
    
    private let koinPolicyButton = UIButton().then { button in
    }
    
    private let licenceButton = UIButton().then { button in
    }
    
    private let versionLabel = InsetLabel(top: 0, left: 24, bottom: 0, right:0).then {
        $0.text = "앱 버전"
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    private let inquryButton = UIButton().then {
        $0.setTitle("문의하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 16)
    }
    
    // MARK: - Initialization
    
    init(viewModel: SettingsViewModel) {
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
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        changePasswordButton.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
        notiButton.addTarget(self, action: #selector(notiButtonTapped), for: .touchUpInside)
        personalPolicyButton.addTarget(self, action: #selector(personalPolicyButtonTapped), for: .touchUpInside)
        koinPolicyButton.addTarget(self, action: #selector(licenseButtonTapped), for: .touchUpInside)
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            }
        }.store(in: &subscriptions)
    }
    
}

extension SettingsViewController {
    @objc private func profileButtonTapped() {
        let viewController = MyProfileViewController(viewModel: MyProfileViewModel(fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), revokeUseCase: DefaultRevokeUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))))
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc private func changePasswordButtonTapped() {
        
    }
    
    @objc private func notiButtonTapped() {
        
    }
    
    @objc private func personalPolicyButtonTapped() {
        
    }
    
    @objc private func koinPolicyButtonTapped() {
        
    }
    
    @objc private func licenseButtonTapped() {
        
    }
    
}

extension SettingsViewController {
    
   
    private func setUpLayOuts() {
        [generalLabel, profileButton, changePasswordButton, notiButton, serviceLabel, personalPolicyButton, koinPolicyButton, licenceButton, versionLabel, inquryButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        generalLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        profileButton.snp.makeConstraints { make in
            make.top.equalTo(generalLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
        }
        changePasswordButton.snp.makeConstraints { make in
            make.top.equalTo(profileButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
        }
        notiButton.snp.makeConstraints { make in
            make.top.equalTo(changePasswordButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
        }
        serviceLabel.snp.makeConstraints { make in
            make.top.equalTo(notiButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        personalPolicyButton.snp.makeConstraints { make in
            make.top.equalTo(serviceLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
        }
        koinPolicyButton.snp.makeConstraints { make in
            make.top.equalTo(personalPolicyButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
        }
        licenceButton.snp.makeConstraints { make in
            make.top.equalTo(koinPolicyButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
        }
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(licenceButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
        }
        inquryButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(24)
            make.bottom.equalTo(view.snp.bottom).offset(-30)
            make.width.equalTo(56)
            make.height.equalTo(26)
        }
    }
    
    private func setUpButtons() {
        let buttons = [profileButton, changePasswordButton, notiButton, personalPolicyButton, koinPolicyButton, licenceButton]
        let buttonTexts = ["프로필", "비밀번호 변경", "알림", "개인정보 처리방침", "코인 이용약관", "오픈소스 라이선스"]
        
        buttons.enumerated().forEach { (index, button) in
            var configuration = UIButton.Configuration.plain()
            if index < 3 {
                configuration.image = UIImage.appImage(asset: .chevronRight)
                configuration.imagePlacement = .trailing
                configuration.imagePadding = 0
                button.contentHorizontalAlignment = .fill
            }
            else {
                button.contentHorizontalAlignment = .leading
            }
            var text = AttributedString(buttonTexts[index])
            text.font = UIFont.appFont(.pretendardRegular, size: 16)
            configuration.attributedTitle = text
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 19)
            button.tintColor = UIColor.appColor(.neutral800)
            button.configuration = configuration
        }
    
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpButtons()
        self.view.backgroundColor = .systemBackground
    }
}
