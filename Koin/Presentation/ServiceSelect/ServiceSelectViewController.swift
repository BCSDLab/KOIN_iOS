//
//  ServiceSelectViewController.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Combine
import SafariServices
import UIKit

final class ServiceSelectViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    private let viewModel: ServiceSelectViewModel
    private let inputSubject: PassthroughSubject<ServiceSelectViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let logoImageview = UIImageView().then {
        $0.image = UIImage.appImage(asset: .mainLogo)
    }
    
    private let nicknameLabel = UILabel().then {
        $0.text = "익명"
        $0.textColor = UIColor.appColor(.primary600)
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
    }
    
    private let makeLoginDescription = UILabel().then {
        $0.text = "로그인 후 더 많은 기능을 이용하세요."
        $0.textColor = UIColor.appColor(.neutral600)
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    private let greetingLabel = UILabel().then {
        $0.text = " 님, 안녕하세요!"
        $0.textColor = UIColor.appColor(.neutral600)
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    private let logOutButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }
    
    private let servicePaddingLabel = UILabel().then {
        $0.backgroundColor = UIColor.appColor(.neutral50)
    }
    
    private let serviceGuideLabel = UILabel().then {
        $0.text = "서비스"
        $0.backgroundColor = UIColor.appColor(.neutral50)
        $0.textColor = UIColor.appColor(.neutral600)
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    private let shopSelectButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }
    
    private let busTimetableButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }

    private let busSearchButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }
    
    private let diningSelectButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }
    
    private let facilityInfoSelectButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }
    
    private let timetableSelectButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }
    
    private let noticeListButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }
    
    private let landSelectButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }
    
    private let businessSelectButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
    }
    
    private let inquryButton = UIButton().then {
        $0.setTitle("문의하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 16)
    }
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    private var chatButton: UIBarButtonItem?
    
    // MARK: - Initialization
    
    init(viewModel: ServiceSelectViewModel) {
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
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let gearImage = UIImage(systemName: "gearshape", withConfiguration: symbolConfig)
        let chatImage = UIImage(systemName: "text.bubble", withConfiguration: symbolConfig)
        let settingButton = UIBarButtonItem(image: gearImage, style: .plain, target: self, action: #selector(settingButtonTapped))
        let chatButton = UIBarButtonItem(image: chatImage, style: .plain, target: self, action: #selector(chatButtonTapped))
        navigationItem.rightBarButtonItems = [settingButton, chatButton]
        configureView()
        setupButtonActions()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavigationBar(style: .empty)
        inputSubject.send(.fetchUserData)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case .disappearProfile:
                self?.changeViewOption(profile: nil)
            case .updateProfile(let profile):
                self?.changeViewOption(profile: profile)
            }
        }.store(in: &subscriptions)
    }
}

extension ServiceSelectViewController {
    
    private func changeViewOption(profile: UserDTO?) {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        var attributedLoginString = AttributedString.init(stringLiteral: "로그인")
        attributedLoginString.font = UIFont.appFont(.pretendardMedium, size: 14)
        var attributedLogoutString = AttributedString.init(stringLiteral: "로그아웃")
        attributedLogoutString.font = UIFont.appFont(.pretendardMedium, size: 14)
        
        if let profile = profile {
            nicknameLabel.isHidden = false
            nicknameLabel.text = profile.nickname ?? "익명"
            config.attributedTitle = attributedLogoutString
            logOutButton.configuration = config
            makeLoginDescription.isHidden = true
            greetingLabel.isHidden = false
        } else {
            nicknameLabel.isHidden = true
            config.attributedTitle = attributedLoginString
            logOutButton.configuration = config
            greetingLabel.isHidden = true
            makeLoginDescription.isHidden = false
        }
        logOutButton.tintColor = UIColor.appColor(.neutral600)
    }
    
    private func setupButtonActions() {
        shopSelectButton.addTarget(self, action: #selector(shopSelectButtonTapped), for: .touchUpInside)
        busTimetableButton.addTarget(self, action: #selector(busTimetableButtonTapped), for: .touchUpInside)
        diningSelectButton.addTarget(self, action: #selector(diningSelectButtonTapped), for: .touchUpInside)
        timetableSelectButton.addTarget(self, action: #selector(timetableSelectButtonTapped), for: .touchUpInside)
        landSelectButton.addTarget(self, action: #selector(landSelectButtonTapped), for: .touchUpInside)
        businessSelectButton.addTarget(self, action: #selector(businessSelectButtonTapped), for: .touchUpInside)
        //     myInfoButton.addTarget(self, action: #selector(myInfoButtonTapped), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)
        inquryButton.addTarget(self, action: #selector(inquryButtonTapped), for: .touchUpInside)
        noticeListButton.addTarget(self, action: #selector(noticeListButtonTapped), for: .touchUpInside)
        facilityInfoSelectButton.addTarget(self, action: #selector(facilityInfoSelectButtonTapped), for: .touchUpInside)
        busSearchButton.addTarget(self, action: #selector(busSearchButtonTapped), for: .touchUpInside)
    }
    
    @objc private func inquryButtonTapped() {
        if let url = URL(string:
                            "https://docs.google.com/forms/d/e/1FAIpQLSeRGc4IIHrsTqZsDLeX__lZ7A-acuioRbABZZFBDY9eMsMTxQ/viewform?usp=sf_link") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func settingButtonTapped() {
        let viewController = SettingsViewController(viewModel: SettingsViewModel(fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))))
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func chatButtonTapped() {
        
        if !viewModel.isLogined {
            showToast(message: "로그인이 필요한 기능입니다.")
            return 
        }
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "쪽지"))
        let viewController = ChatListTableViewController(viewModel: ChatListTableViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func logOutButtonTapped() {
        if viewModel.isLogined {
            showLogOutAlert()
        } else {
            let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
            loginViewController.title = "로그인"
            navigationController?.pushViewController(loginViewController, animated: true)
            
            inputSubject.send(.logEvent(EventParameter.EventLabel.User.hamburgerLogin, .click, "햄버거 로그인"))
        }
    }
    @objc private func timetableSelectButtonTapped() {
        
        if viewModel.isLogined {
            let viewController = TimetableViewController(viewModel: TimetableViewModel())
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            showToast(message: "로그인이 필요한 기능입니다.", success: true)
        }
    }
    
    @objc func noticeListButtonTapped() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "공지사항"))
        let noticeService = DefaultNoticeService()
        let noticeRepository = DefaultNoticeListRepository(service: noticeService)
        let fetchNoticeArticlesUseCase = DefaultFetchNoticeArticlesUseCase(noticeListRepository: noticeRepository)
        let fetchMyKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NoticeListViewModel(fetchNoticeArticlesUseCase: fetchNoticeArticlesUseCase, fetchMyKeywordUseCase: fetchMyKeywordUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let noticeListViewController = NoticeListViewController(viewModel: viewModel)
        navigationController?.pushViewController(noticeListViewController, animated: true)
    }
    
    @objc func shopSelectButtonTapped() {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        
        let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
        let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
        let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository)
        let searchShopUseCase = DefaultSearchShopUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        
        let viewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase, searchShopUseCase: searchShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            selectedId: 0
        )
        let shopViewController = ShopViewControllerA(viewModel: viewModel)
        shopViewController.title = "주변상점"
        navigationController?.pushViewController(shopViewController, animated: true)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.hamburger, .click, "주변상점"))
    }
    
    @objc func busTimetableButtonTapped() {
        let repository = DefaultBusRepository(service: DefaultBusService())
        let viewModel = BusTimetableViewModel(fetchExpressTimetableUseCase: DefaultFetchExpressTimetableUseCase(busRepository: repository), getExpressFiltersUseCase: DefaultGetExpressFilterUseCase(), getCityFiltersUseCase: DefaultGetCityFiltersUseCase(), fetchCityTimetableUseCase: DefaultFetchCityBusTimetableUseCase(busRepository: repository), getShuttleFilterUseCase: DefaultGetShuttleBusFilterUseCase(), fetchShuttleRoutesUseCase: DefaultFetchShuttleBusRoutesUseCase(busRepository: repository), fetchEmergencyNoticeUseCase: DefaultFetchEmergencyNoticeUseCase(repository: repository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
        let viewController = BusTimetableViewController(viewModel: viewModel)
        viewController.title = "버스 시간표"
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "버스 시간표"))
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func busSearchButtonTapped() {
        let viewModel = BusSearchViewModel(selectBusAreaUseCase: DefaultSelectDepartAndArrivalUseCase(), fetchEmergencyNoticeUseCase: DefaultFetchEmergencyNoticeUseCase(repository: DefaultBusRepository(service: DefaultBusService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
        let viewController = BusSearchViewController(viewModel: viewModel)
        viewController.title = "교통편 조회하기"
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "교통편 조회하기"))
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func diningSelectButtonTapped() {
        let diningService = DefaultDiningService()
        let shareService = KakaoShareService()
        let diningRepository = DefaultDiningRepository(diningService: diningService, shareService: shareService)
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let diningLikeUseCase = DefaultDiningLikeUseCase(diningRepository: diningRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let dateProvider = DefaultDateProvider()
        let shareMenuListUseCase = DefaultShareMenuListUseCase(diningRepository: diningRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, diningLikeUseCase: diningLikeUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase, assignAbTestUseCase: DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService())))
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"
        navigationController?.pushViewController(diningViewController, animated: true)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "식단"))
    }
    /*
     @objc func timetableSelectButtonTapped() {
     /*
      let timetableViewController = TimetableViewController(viewModel: TimetableViewModel(service: TimetableService(provider: APIProvider(session: URLSession.shared))))
      timetableViewController.title = "시간표"
      navigationController?.pushViewController(timetableViewController, animated: true)*/
     }
     */
    
    @objc func facilityInfoSelectButtonTapped() {
        let viewController = FacilityInfoViewController()
        navigationController?.pushViewController(viewController, animated: true)
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "교내 시설물 정보"))
    }
    
    @objc func landSelectButtonTapped() {
        let landService = DefaultLandService()
        let landRepository = DefaultLandRepository(service: landService)
        let fetchLandListUseCase = DefaultFetchLandListUseCase(landRepository: landRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = LandViewModel(fetchLandListUseCase: fetchLandListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let landViewController = LandViewController(viewModel: viewModel)
        landViewController.title = "복덕방"
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.hamburger, .click, "복덕방"))
        navigationController?.pushViewController(landViewController, animated: true)
    }
    
    @objc func businessSelectButtonTapped() {
        if let url = URL(string: "https://owner.koreatech.in/") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
        }
    }
    
    private func showLoginAlert() {
        let alertTitle = "로그인"
        let alertMessage = "로그인 하시겠습니까?"
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            
            let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
            
            loginViewController.title = "로그인"
            self?.navigationController?.pushViewController(loginViewController, animated: true)
            
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.User.userOnlyOk, .click, "회원전용 확인"))
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showLogOutAlert() {
        let alertTitle = "로그아웃"
        let alertMessage = "로그아웃 하시겠습니까?"
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.inputSubject.send(.logOut)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ServiceSelectViewController {
    
    private func setUpLayOuts() {
        [scrollView, inquryButton].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(contentView)
        [nicknameLabel, greetingLabel, servicePaddingLabel, serviceGuideLabel, shopSelectButton, busTimetableButton, busSearchButton, diningSelectButton, landSelectButton, businessSelectButton, logOutButton, makeLoginDescription, noticeListButton, facilityInfoSelectButton, timetableSelectButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpDetailLayout() {
        let kindOfButton = [noticeListButton, busTimetableButton, busSearchButton, shopSelectButton, diningSelectButton, timetableSelectButton, facilityInfoSelectButton, landSelectButton, businessSelectButton]
        let buttonName = ["게시판", "버스 시간표", "교통편 조회하기", "주변 상점", "식단", "시간표", "교내 시설물 정보", "복덕방", "코인 for Business"]
        for idx in 0..<buttonName.count {
            var config = UIButton.Configuration.plain()
            config.contentInsets = .init(top: 16, leading: 24, bottom: 16, trailing: 24)
            var attributedString = AttributedString.init(stringLiteral: buttonName[idx])
            attributedString.font = UIFont.appFont(.pretendardRegular, size: 16)
            config.attributedTitle = attributedString
            kindOfButton[idx].configuration = config
            kindOfButton[idx].tintColor = UIColor.appColor(.neutral800)
            kindOfButton[idx].layer.borderWidth = 1
            kindOfButton[idx].layer.borderColor = UIColor.appColor(.neutral100).cgColor
        }
        
        [logOutButton].forEach {
            var config = UIButton.Configuration.plain()
            config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            var attributedString = AttributedString.init(stringLiteral: "로그아웃")
            attributedString.font = UIFont.appFont(.pretendardMedium, size: 14)
            config.attributedTitle = attributedString
            $0.configuration = config
            $0.tintColor = UIColor.appColor(.neutral600)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inquryButton.snp.top).offset(-10)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(750)
        }
        
        inquryButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(24)
            make.bottom.equalTo(view.snp.bottom).offset(-30)
            make.width.equalTo(56)
            make.height.equalTo(26)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalTo(contentView.snp.leading).offset(24)
        }
        
        makeLoginDescription.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalTo(contentView.snp.leading).offset(24)
        }
        
        greetingLabel.snp.makeConstraints { make in
            make.bottom.equalTo(nicknameLabel.snp.bottom)
            make.leading.equalTo(nicknameLabel.snp.trailing)
        }
        
        logOutButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(33.5)
            make.trailing.equalTo(contentView.snp.trailing).offset(-24)
            make.height.equalTo(17)
            make.width.equalTo(60)
        }
        
        servicePaddingLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(140)
            make.leading.equalTo(contentView.snp.leading)
            make.width.equalTo(24)
            make.height.equalTo(33)
        }
        
        serviceGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(servicePaddingLabel)
            make.leading.equalTo(servicePaddingLabel.snp.trailing)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(33)
        }
        
        noticeListButton.snp.makeConstraints { make in
            make.top.equalTo(serviceGuideLabel.snp.bottom)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(58)
        }
        
        shopSelectButton.snp.makeConstraints { make in
            make.top.equalTo(busSearchButton.snp.bottom)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(58)
        }
        
        busTimetableButton.snp.makeConstraints { make in
            make.top.equalTo(noticeListButton.snp.bottom)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(58)
        }
        
        busSearchButton.snp.makeConstraints { make in
            make.top.equalTo(busTimetableButton.snp.bottom)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(58)
        }
        
        diningSelectButton.snp.makeConstraints { make in
            make.top.equalTo(shopSelectButton.snp.bottom)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(58)
        }
        
        timetableSelectButton.snp.makeConstraints { make in
            make.top.equalTo(diningSelectButton.snp.bottom)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(58)
        }
        
        facilityInfoSelectButton.snp.makeConstraints { make in
            make.top.equalTo(timetableSelectButton.snp.bottom)
            make.leading.trailing.equalTo(contentView)
            make.height.equalTo(58)
        }
        
        landSelectButton.snp.makeConstraints { make in
            make.top.equalTo(facilityInfoSelectButton.snp.bottom)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
        }
        
        businessSelectButton.snp.makeConstraints { make in
            make.top.equalTo(landSelectButton.snp.bottom)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.height.equalTo(58)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpDetailLayout()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
