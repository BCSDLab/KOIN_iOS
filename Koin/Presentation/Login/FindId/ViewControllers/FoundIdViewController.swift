//
//  FoundIdViewController.swift
//  koin
//
//  Created by 김나훈 on 6/17/25.
//

import Combine
import UIKit

final class FoundIdViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FindIdViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let messageLabel = UILabel().then {
        $0.text = "아이디 조회 결과"
    }
    
    private let subMessageLabel = UILabel()
    
    private let loginButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.sub500)
        $0.setTitle("로그인 바로가기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.layer.cornerRadius = 8
    }
    
    private let registerButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("비밀번호 찾기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.layer.cornerRadius = 8
    }
    
    init(viewModel: FindIdViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "아이디 찾기"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        updateSubMessageLabel(with: viewModel.loginId ?? "")
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    // MARK: - Bind
    
    private func bind() {
        
    }
}

extension FoundIdViewController {
    @objc private func loginButtonTapped() {
        let homeViewController = makeHomeViewController()
        let serviceSelectViewController = ServiceSelectViewController(viewModel: ServiceSelectViewModel(fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        let viewControllers = [homeViewController, serviceSelectViewController, loginViewController]
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    @objc private func registerButtonTapped() {
        let homeViewController = makeHomeViewController()
        let serviceSelectViewController = ServiceSelectViewController(viewModel: ServiceSelectViewModel(fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        let findPasswordViewController = FindPasswordCertViewController(viewModel: FindPasswordViewModel())
        let viewControllers = [homeViewController, serviceSelectViewController, findPasswordViewController]
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    private func makeHomeViewController() -> UIViewController {
        let diningRepository = DefaultDiningRepository(diningService: DefaultDiningService(), shareService: KakaoShareService())
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let fetchShopCategoryUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: DefaultNoticeListRepository(service: DefaultNoticeService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let dateProvider = DefaultDateProvider()
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let fetchLostItemStatsUseCase = DefaultFetchLostItemStatsUseCase(repository: DefaultLostItemRepository(service: DefaultLostItemService()))
        
        let homeViewModel = HomeViewModel(
            fetchDiningListUseCase: fetchDiningListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryUseCase,
            dateProvider: dateProvider,
            checkVersionUseCase: DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService())),
            assignAbTestUseCase: DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService())),
            fetchKeywordNoticePhraseUseCase: DefaultFetchKeywordNoticePhraseUseCase(),
            checkLoginUseCase: checkLoginUseCase,
            fetchLostItemStatsUseCase: fetchLostItemStatsUseCase
        )
        let viewController = HomeViewController(viewModel: homeViewModel)
        return viewController
    }
    func updateSubMessageLabel(with id: String) {
        let baseText = "아이디는 \(id)입니다."
        let attributed = NSMutableAttributedString(string: baseText)
        
        let fullFont = UIFont.appFont(.pretendardRegular, size: 16)
        let fullColor = UIColor.appColor(.gray)
        
        let highlightFont = UIFont.appFont(.pretendardMedium, size: 20)
        let highlightColor = UIColor.black
        
        attributed.addAttribute(.font, value: fullFont, range: NSRange(location: 0, length: baseText.count))
        attributed.addAttribute(.foregroundColor, value: fullColor, range: NSRange(location: 0, length: baseText.count))
        
        if let idRange = baseText.range(of: id) {
            let nsRange = NSRange(idRange, in: baseText)
            attributed.addAttribute(.font, value: highlightFont, range: nsRange)
            attributed.addAttribute(.foregroundColor, value: highlightColor, range: nsRange)
        }
        
        subMessageLabel.attributedText = attributed
    }
}

extension FoundIdViewController {
    
    private func setupLayOuts() {
        [messageLabel, subMessageLabel, loginButton, registerButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-100)
            $0.centerX.equalToSuperview()
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
        loginButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(64)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(48)
            $0.height.equalTo(48)
        }
        registerButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(48)
            $0.height.equalTo(48)
        }
    }
    
    private func setupComponents() {
        messageLabel.font = UIFont.appFont(.pretendardBold, size: 24)
        messageLabel.textColor = UIColor.appColor(.primary500)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
