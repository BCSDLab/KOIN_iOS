//
//  ChangePasswordSuccessViewController.swift
//  koin
//
//  Created by 김나훈 on 6/19/25.
//

import Combine
import UIKit

final class ChangePasswordSuccessViewController: UIViewController {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let circleImageView = UIImageView().then {
        $0.image = UIImage(named: "checkFilledCircle")
    }
    
    private let messageLabel = UILabel().then {
        $0.text = "비밀번호 변경 완료"
    }
    private let subMessageLabel = UILabel().then {
        $0.text = "비밀번호가 변경되었습니다.\n새로운 비밀번호로 로그인 부탁드립니다."
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    private let goLoginButton = StateButton(font: UIFont.appFont(.pretendardBold, size: 15)).then {
        $0.setState(state: .usable)
        $0.setTitle("로그인 화면 바로가기", for: .normal)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "비밀번호 찾기"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupUI()
        bind()
        goLoginButton.addTarget(self, action: #selector(goLoginButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    // MARK: - Bind
    
    private func bind() {
       
    }
}

extension ChangePasswordSuccessViewController {
    @objc private func goLoginButtonTapped() {
        let homeViewController = makeHomeViewController()
        let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        let viewControllers = [homeViewController, loginViewController]
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
        let checkLoginUseCase = DefaultCheckLoginUseCase(
            userRepository: DefaultUserRepository(service: DefaultUserService())
        )
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
}

extension ChangePasswordSuccessViewController {
    
    private func setupLayOuts() {
        [circleImageView, messageLabel, subMessageLabel, goLoginButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        circleImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
            $0.size.equalTo(55)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(circleImageView.snp.bottom).offset(36)
            $0.centerX.equalToSuperview()
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        goLoginButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(36)
            $0.horizontalEdges.equalToSuperview().inset(48)
            $0.width.equalTo(294)
            $0.height.equalTo(44)
        }
    }
    
    private func setupComponents() {
        messageLabel.font = UIFont.appFont(.pretendardBold, size: 24)
        messageLabel.textColor = UIColor.appColor(.primary500)
        subMessageLabel.font = UIFont.appFont(.pretendardMedium, size: 16)
        subMessageLabel.textColor = UIColor.appColor(.gray)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
