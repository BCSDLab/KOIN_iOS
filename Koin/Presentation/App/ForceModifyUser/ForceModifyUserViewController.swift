//
//  ForceModifyUserViewController.swift
//  koin
//
//  Created by 김나훈 on 7/14/25.
//

import Combine
import UIKit
import Lottie

@MainActor
protocol ForceModifyUserViewControllerCoordinator: AnyObject {
    func modifyUserButtonTapped()
}

final class ForceModifyUserViewController: UIViewController, LottieAnimationManageable {
    
    // MARK: - LottieAnimationManageable Protocol
    var lottieAnimationView: LottieAnimationView {
        return logoAnimationView
    }
    
    // MARK: - Properties
    weak var coordinator: ForceModifyUserViewControllerCoordinator?
    
    // MARK: - UI Components
    private let contentViewLayoutGuide = UILayoutGuide()
    
    private let contentView = UIView()
    
    private let logoAnimationView = LottieAnimationView().then {
        $0.animation = LottieAnimation.named("waveLogo")
        $0.loopMode = .loop
        $0.animationSpeed = 1.0
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
    }
    
    private let messageLabel = UILabel().then {
        $0.text = "새로워진 코인, 준비 완료!"
    }
    
    private let subMessageLabel = UILabel().then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 14 * 0.6
        $0.attributedText = NSAttributedString(
            string: "몇 가지 정보만 더 입력해주시면\n더 편하고 똑똑하게 이용하실 수 있어요!",
            attributes: [
                .font : UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor : UIColor.appColor(.gray),
                .paragraphStyle : paragraphStyle
            ]
        )
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    private let navigateButton = UIButton().then {
        $0.setTitle("정보 입력하러 가기", for: .normal)
    }
    
    // MARK: - Initializer
    init(coordinator: ForceModifyUserViewControllerCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - deinit
    deinit {
        clearLottieAnimation()
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigateButton.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
        setupLottie()
        startLottieAnimation()
    }
}

extension ForceModifyUserViewController {
    @objc private func navigateButtonTapped() {
        coordinator?.modifyUserButtonTapped()
    }
    
    private func makeHomeTabbarController() -> HomeTabbarController {
        let homeRootView = makeHomeView()
        let homeViewController = HomeHostingController(rootView: homeRootView)

        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let categoryRootView = CategoryView(viewModel: CategoryViewModel(logAnalyticsEventUseCase: logAnalyticsEventUseCase))
        let categoryViewController = CategoryHostingController(rootView: categoryRootView)

        let noticeViewController = makeNoticeListViewController()
        let profileViewController = UIViewController()
        
        let viewModel = HomeTabbarViewModel(logAnalyticsEventUseCase: logAnalyticsEventUseCase)

        return HomeTabbarController(
            homeViewController: homeViewController,
            categoryViewController: categoryViewController,
            noticeViewController: noticeViewController,
            profileViewController: profileViewController,
            viewModel: viewModel
        )
    }

    private func makeHomeView() -> HomeView {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let coreRepository = DefaultCoreRepository(service: DefaultCoreService())
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let diningRepository = DefaultDiningRepository(diningService: DefaultDiningService(), shareService: KakaoShareService())
        let homeRepository = DefaultHomeRepository(service: DefaultHomeService())

        let fetchHomeHeaderUseCase = DefaultFetchHomeHeaderUseCase(homeRepository: homeRepository, userRepository: userRepository)
        let fetchHomeDiningListUseCase = DefaultFetchHomeDiningListUseCase(
            fetchDiningListUseCase: DefaultFetchDiningListUseCase(diningRepository: diningRepository),
            fetchCoopShopListUseCase: DefaultFetchCoopShopListUseCase(diningRepository: diningRepository),
            dateProvider: DefaultDateProvider()
        )
        let fetchCountsUseCase = DefaultFetchNewHomeCountsUseCase(
            shopRepository: shopRepository,
            callvanRepository: callVanRepository
        )
        let checkVersionUseCase = DefaultCheckVersionUseCase(coreRepository: coreRepository)
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: userRepository)
        let SendDeviceTokenIfNeededUseCase = DefaultSendDeviceTokenIfNeededUseCase(
            userRepository: userRepository,
            notiRepository: notiRepository
        )
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        
        let viewModel = NewHomeViewModel(
            fetchHomeHeaderUseCase: fetchHomeHeaderUseCase,
            fetchHomeDiningListUseCase: fetchHomeDiningListUseCase,
            fetchCountsUseCase: fetchCountsUseCase,
            checkLoginUseCase: DefaultCheckLoginUseCase(userRepository: userRepository),
            sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            fetchBannerUseCase: DefaultFetchBannerUseCase(coreRepository: coreRepository),
            shouldPresentBanner: false
        )
        return HomeView(viewModel: viewModel)
    }
    
    private func makeNoticeListViewController() -> UIViewController {
        let service = DefaultNoticeService()
        let repository = DefaultNoticeListRepository(service: service)
        let fetchArticleListUseCase = DefaultFetchNoticeArticlesUseCase(noticeListRepository: repository)
        let fetchMyKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(
            repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
        )
        let viewModel = NoticeListViewModel(
            fetchNoticeArticlesUseCase: fetchArticleListUseCase,
            fetchMyKeywordUseCase: fetchMyKeywordUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        return NoticeListViewController(viewModel: viewModel)
    }

}

extension ForceModifyUserViewController {
    
    private func setupLayOuts() {
        [contentView, logoAnimationView, messageLabel, subMessageLabel, navigateButton].forEach {
            view.addSubview($0)
        }
        
        [contentViewLayoutGuide].forEach {
            view.addLayoutGuide($0)
        }
    }
    
    private func setupConstraints() {
        contentViewLayoutGuide.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(navigateButton.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.center.equalTo(contentViewLayoutGuide)
        }
        
        logoAnimationView.snp.makeConstraints {
            $0.top.centerX.equalTo(contentView)
            $0.width.equalTo(240)
            $0.height.equalTo(140)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(logoAnimationView.snp.bottom).offset(27)
            $0.centerX.equalTo(contentView)
            $0.height.equalTo(32)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.bottom.centerX.equalTo(contentView)
        }
        navigateButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(46)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        messageLabel.font = UIFont.appFont(.pretendardBold, size: 20)
        messageLabel.textColor = .black
        navigateButton.backgroundColor = UIColor.appColor(.new500)
        navigateButton.layer.cornerRadius = 8
        navigateButton.layer.masksToBounds = true
        navigateButton.setTitleColor(UIColor.white, for: .normal)
        navigateButton.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
