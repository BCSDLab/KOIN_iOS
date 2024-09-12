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
    
    private let nowVersionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let recentVersionLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
    }
    private let inquryButton = UIButton().then {
        $0.setTitle("문의하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 16)
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "설정"
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
        koinPolicyButton.addTarget(self, action: #selector(koinPolicyButtonTapped), for: .touchUpInside)
        licenceButton.addTarget(self, action: #selector(licenseButtonTapped), for: .touchUpInside)
        inquryButton.addTarget(self, action: #selector(inquryButtonTapped), for: .touchUpInside)
        nowVersionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        navigationController?.setNavigationBarHidden(false, animated: true)
        // 이것들 시점 usecase나 뷰모델이나 그런데로 다 뺴기
        fetchAppStoreVersion(bundleID: Bundle.main.bundleIdentifier ?? "") { [weak self] appStoreVersion in
            guard let self = self else { return }
            if let version = appStoreVersion {
                // UI 업데이트는 메인 스레드에서 수행
                DispatchQueue.main.async {
                    if version == self.nowVersionLabel.text {
                        self.recentVersionLabel.text = "현재 최신 버전 입니다."
                        self.recentVersionLabel.textColor = UIColor.appColor(.neutral400)
                    } else {
                        self.recentVersionLabel.text = "최신 버전 \(version)"
                        self.recentVersionLabel.textColor = UIColor.appColor(.primary500)
                    }
                }
            }
        }

        
    }
    
    
    // MARK: - Bind
    
    private func bind() {
      
    }
    
}

extension SettingsViewController {
    
    func fetchAppStoreVersion(bundleID: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleID)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String {
                    completion(appStoreVersion)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    

    @objc private func profileButtonTapped() {
        let viewController = MyProfileViewController(viewModel: MyProfileViewModel(fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), revokeUseCase: DefaultRevokeUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))))
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc private func changePasswordButtonTapped() {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: userRepository)
        let checkPasswordUseCase = DefaultCheckPasswordUseCase(userRepository: userRepository)
        let modifyUseCase = DefaultModifyUseCase(userRepository: userRepository)
        let viewController = ChangePasswordViewController(viewModel: ChangePasswordViewModel(fetchUserDataUseCase: fetchUserDataUseCase, checkPasswordUseCase: checkPasswordUseCase, modifyUseCase: modifyUseCase))
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func notiButtonTapped() {
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewController = NotiViewController(viewModel: NotiViewModel(changeNotiUseCase: changeNotiUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase, fetchNotiListUseCase: fetchNotiListUseCase))
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func personalPolicyButtonTapped() {
        let viewController = PolicyViewController(policyType: .personalInformation)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func koinPolicyButtonTapped() {
        let viewController = PolicyViewController(policyType: .koin)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func licenseButtonTapped() {
        showToast(message: "아직 디자인이 안나온것 같아요~", success: true)
    }
    @objc private func inquryButtonTapped() {
        showToast(message: "아직 구글폼 완성이 안된것같아요~", success: true)
    }
}

extension SettingsViewController {
    
   
    private func setUpLayOuts() {
        [generalLabel, profileButton, changePasswordButton, notiButton, serviceLabel, personalPolicyButton, koinPolicyButton, licenceButton, versionLabel, nowVersionLabel, recentVersionLabel, inquryButton].forEach {
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
        nowVersionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(versionLabel.snp.centerY).offset(-2)
            make.trailing.equalTo(view.snp.trailing).offset(-27.5)
        }
        recentVersionLabel.snp.makeConstraints { make in
            make.top.equalTo(versionLabel.snp.centerY).offset(2)
            make.trailing.equalTo(view.snp.trailing).offset(-27.5)
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
