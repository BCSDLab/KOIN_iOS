//
//  ForceModifyUserViewController.swift
//  koin
//
//  Created by 김나훈 on 7/14/25.
//

import Combine
import UIKit
import Lottie

final class ForceModifyUserViewController: UIViewController, LottieAnimationManageable {
    
    // MARK: - LottieAnimationManageable Protocol
    var lottieAnimationView: LottieAnimationView {
        return logoAnimationView
    }
    
    // MARK: - Properties
    var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
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
        $0.text = "몇 가지 정보만 더 입력해주시면\n더 편하고 똑똑하게 이용하실 수 있어요!"
    }
    
    private let navigateButton = UIButton().then {
        $0.setTitle("정보 입력하러 가기", for: .normal)
    }
    
    // MARK: - deinit
    deinit {
        clearLottieAnimation()
    }

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        navigateButton.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
        setupLottie()
        startLottieAnimation()
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        
    }
}

extension ForceModifyUserViewController {
    @objc private func navigateButtonTapped() {
        let homeViewController = makeHomeTabbarController()

        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let modifyUseCase = DefaultModifyUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let fetchDeptListUseCase = DefaultFetchDeptListUseCase(timetableRepository: DefaultTimetableRepository(service: DefaultTimetableService()))
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let checkDuplicatedNicknameUseCase = DefaultCheckDuplicatedNicknameUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))

        let changeMyProfileViewController = ChangeMyProfileViewController(viewModel: ChangeMyProfileViewModel(modifyUseCase: modifyUseCase, fetchDeptListUseCase: fetchDeptListUseCase, fetchUserDataUseCase: fetchUserDataUseCase, checkDuplicatedNicknameUseCase: checkDuplicatedNicknameUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase), userType: .student)
        navigationController?.setViewControllers([homeViewController, changeMyProfileViewController], animated: true)
        
    }
    
    private func makeHomeTabbarController() -> HomeTabbarController {
        let homeRootView = makeHomeView()
        let homeViewController = HomeHostingController(rootView: homeRootView)

        let categoryRootView = CategoryView()
        let categoryViewController = CategoryHostingController(rootView: categoryRootView)

        let noticeViewController = makeNoticeListViewController()
        let profileViewController = UIViewController()

        return HomeTabbarController(
            homeViewController: homeViewController,
            categoryViewController: categoryViewController,
            noticeViewController: noticeViewController,
            profileViewController: profileViewController
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
            
        let viewModel = NewHomeViewModel(
            fetchHomeHeaderUseCase: fetchHomeHeaderUseCase,
            fetchHomeDiningListUseCase: fetchHomeDiningListUseCase,
            fetchCountsUseCase: fetchCountsUseCase,
            checkVersionUseCase: checkVersionUseCase,
            fetchUserDataUseCase: fetchUserDataUseCase,
            sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase
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
        [logoAnimationView, messageLabel, subMessageLabel, navigateButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        logoAnimationView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-50)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(240)
            $0.height.equalTo(140)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(logoAnimationView.snp.bottom).offset(27)
            $0.centerX.equalToSuperview()
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
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
        subMessageLabel.font = UIFont.appFont(.pretendardRegular, size: 14)
        subMessageLabel.textColor = UIColor.appColor(.gray)
        subMessageLabel.numberOfLines = 2
        subMessageLabel.textAlignment = .center
        navigateButton.backgroundColor = UIColor(hexCode: "#B611F5")
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
