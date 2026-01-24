//
//  ServiceSelectViewController.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Combine
import SafariServices
import UIKit

final class ServiceSelectViewController: UIViewController {
    
    
    // MARK: - Properties
    private let viewModel: ServiceSelectViewModel
    private let inputSubject = PassthroughSubject<ServiceSelectViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private lazy var serviceSelectTableHeaderView = ServiceSelectTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 110))
    private lazy var serviceSelectTableView = ServiceSelectTableView().then {        
        $0.rowHeight = 58
        $0.sectionHeaderHeight = 38
        $0.sectionFooterHeight = 0
        $0.sectionHeaderTopPadding = 0
        $0.tableHeaderView = serviceSelectTableHeaderView
    }
    private let inquaryButton = UIButton().then {
        $0.setTitle("문의하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        $0.setAttributedTitle(NSAttributedString(string: "문의하기", attributes: [
            .font: UIFont.appFont(.pretendardRegular, size: 16),
            .foregroundColor: UIColor.appColor(.neutral800)
        ]), for: .normal)
    }
    
    // MARK: - Initializer
    init(viewModel: ServiceSelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addTarget()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavigationBar(style: .empty)
        configureRightBarButtons()
        inputSubject.send(.fetchUserData)
    }
    
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
        
        serviceSelectTableHeaderView.loginButtonTappedPublisher.sink { [weak self] in
            self?.loginButtonTapped()
        }.store(in: &subscriptions)
        
        serviceSelectTableView.serviceTappedPublisher.sink { [weak self] service in
            guard let self else { return }
            switch service {
            case .notice:
                self.pushNoticeList()
            case .busTimeTable:
                self.pushBusTimetable()
            case .busSearch:
                self.pushBusSearch()
            case .shop:
                self.pushShop()
            case .dining:
                self.pushDining()
            case .timetable:
                self.pushTimetable()
            case .facility:
                self.pushFacility()
            case .land:
                self.pushLand()
            case .business:
                self.presentBusiness()
            case .lostItem:
                self.pushLostItem()
            }
        }.store(in: &subscriptions)
    }
    
    private func addTarget() {
        inquaryButton.addTarget(self, action: #selector(inquryButtonTapped), for: .touchUpInside)
    }
    
    private func configureRightBarButtons() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let gearImage = UIImage(systemName: "gearshape", withConfiguration: symbolConfig)
        let chatImage = UIImage(systemName: "text.bubble", withConfiguration: symbolConfig)
        let settingButton = UIBarButtonItem(image: gearImage, style: .plain, target: self, action: #selector(settingButtonTapped))
        let chatButton = UIBarButtonItem(image: chatImage, style: .plain, target: self, action: #selector(chatButtonTapped))
        navigationItem.rightBarButtonItems = [settingButton, chatButton]
    }
}

extension ServiceSelectViewController {
    private func changeViewOption(profile: UserDto?) {
        if let profile = profile {
            serviceSelectTableHeaderView.showName(name: profile.nickname ?? "익명")
        }
        else {
            serviceSelectTableHeaderView.hideName()
        }
    }
    
    private func loginButtonTapped() {
        if viewModel.isLogined {
            showLogOutAlert()
        } else {
            inputSubject.send(.logEvent(EventParameter.EventLabel.User.hamburger, .click, "로그인 시도"))
            pushLogin()
        }
    }
    
    private func showLogOutAlert() {
        let alertTitle = "로그아웃"
        let alertMessage = "로그아웃 하시겠습니까?"
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.inputSubject.send(.logOut)
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.User.hamburger, .click, "로그아웃"))
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ServiceSelectViewController {
    
    private func pushLostItem() {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let fetchLostItemItemUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
        let viewModel = LostItemListViewModel(checkLoginUseCase: checkLoginUseCase, fetchLostItemItemUseCase: fetchLostItemItemUseCase)
        let viewController = LostItemListViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushLogin() {
        let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        loginViewController.title = "로그인"
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    private func pushNoticeList() {
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
    
    private func pushBusTimetable() {
        let repository = DefaultBusRepository(service: DefaultBusService())
        let viewModel = BusTimetableViewModel(fetchExpressTimetableUseCase: DefaultFetchExpressTimetableUseCase(busRepository: repository), getExpressFiltersUseCase: DefaultGetExpressFilterUseCase(), getCityFiltersUseCase: DefaultGetCityFiltersUseCase(), fetchCityTimetableUseCase: DefaultFetchCityBusTimetableUseCase(busRepository: repository), getShuttleFilterUseCase: DefaultGetShuttleBusFilterUseCase(), fetchShuttleRoutesUseCase: DefaultFetchShuttleBusRoutesUseCase(busRepository: repository), fetchEmergencyNoticeUseCase: DefaultFetchEmergencyNoticeUseCase(repository: repository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
        let viewController = BusTimetableViewController(viewModel: viewModel)
        viewController.title = "버스 시간표"
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "버스 시간표"))
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushBusSearch() {
        let viewModel = BusSearchViewModel(selectBusAreaUseCase: DefaultSelectDepartAndArrivalUseCase(), fetchEmergencyNoticeUseCase: DefaultFetchEmergencyNoticeUseCase(repository: DefaultBusRepository(service: DefaultBusService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
        let viewController = BusSearchViewController(viewModel: viewModel)
        viewController.title = "교통편 조회하기"
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "교통편 조회하기"))
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushShop() {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
        let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
        let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let viewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase
        )
        let viewController = ShopViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.hamburger, .click, "주변상점"))
    }
    
    private func pushDining() {
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
    
    private func pushTimetable() {
        if viewModel.isLogined {
            let viewController = TimetableViewController(viewModel: TimetableViewModel())
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            showToast(message: "로그인이 필요한 기능입니다.", success: true)
        }
    }
    
    private func pushFacility() {
        let viewController = FacilityInfoViewController()
        navigationController?.pushViewController(viewController, animated: true)
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "교내 시설물 정보"))
    }
    
    private func pushLand() {
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
    
    private func presentBusiness() {
        if let url = URL(string: "https://owner.koreatech.in/") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
        }
    }
}

// MARK: - @objc
extension ServiceSelectViewController {
    @objc private func inquryButtonTapped() {
        if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSeRGc4IIHrsTqZsDLeX__lZ7A-acuioRbABZZFBDY9eMsMTxQ/viewform?usp=sf_link") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func settingButtonTapped() {
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewController = SettingsViewController(viewModel: SettingsViewModel(logAnalyticsEventUseCase: logAnalyticsEventUseCase))
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
    
}

extension ServiceSelectViewController {
    
    private func setLayouts() {
        [serviceSelectTableView, inquaryButton].forEach {
            view.addSubview($0)
        }
    }
    private func setConstraints() {
        serviceSelectTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inquaryButton.snp.top).offset(-10)
        }
        inquaryButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-30)
            $0.height.equalTo(26)
        }
    }
    private func configureView() {
        setLayouts()
        setConstraints()
        view.backgroundColor = .appColor(.neutral0)
    }
}
