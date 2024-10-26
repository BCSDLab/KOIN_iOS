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
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.appImage(symbol: .chevronLeft), for: .normal)
        button.tintColor = UIColor.appColor(.neutral800)
        return button
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.appImage(asset: .gear), for: .normal)
        button.tintColor = UIColor.appColor(.neutral800)
        return button
    }()
    
    private let logoImageview: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.appImage(asset: .mainLogo)
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "익명"
        label.textColor = UIColor.appColor(.primary600)
        label.font = UIFont.appFont(.pretendardBold, size: 16)
        return label
    }()
    
    private let makeLoginDescription: UILabel = {
        let label = UILabel()
        label.text = "로그인 후 더 많은 기능을 이용하세요."
        label.textColor = UIColor.appColor(.neutral600)
        label.font = UIFont.appFont(.pretendardMedium, size: 14)
        return label
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.text = " 님, 안녕하세요!"
        label.textColor = UIColor.appColor(.neutral600)
        label.font = UIFont.appFont(.pretendardMedium, size: 14)
        return label
    }()
    
    private let logOutButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let servicePaddingLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.appColor(.neutral50)
        return label
    }()
    
    private let serviceGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "서비스"
        label.backgroundColor = UIColor.appColor(.neutral50)
        label.textColor = UIColor.appColor(.neutral600)
        label.font = UIFont.appFont(.pretendardMedium, size: 14)
        return label
    }()
    
    private let shopSelectButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let busSelectButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let diningSelectButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let facilityInfoSelectButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let timetableSelectButton: UIButton = {
        let button = UIButton()
        button.setTitle("시간표", for: .normal)
        button.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 16)
        return button
    }()
    
    private let noticeListButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let landSelectButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let businessSelectButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let inquryButton = UIButton().then {
        $0.setTitle("문의하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 16)
    }

    
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
        configureView()
        setupButtonActions()
        bind()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        inputSubject.send(.fetchUserData)
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
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        shopSelectButton.addTarget(self, action: #selector(shopSelectButtonTapped), for: .touchUpInside)
        busSelectButton.addTarget(self, action: #selector(busSelectButtonTapped), for: .touchUpInside)
        diningSelectButton.addTarget(self, action: #selector(diningSelectButtonTapped), for: .touchUpInside)
        //timetableSelectButton.addTarget(self, action: #selector(timetableSelectButtonTapped), for: .touchUpInside)
        landSelectButton.addTarget(self, action: #selector(landSelectButtonTapped), for: .touchUpInside)
        businessSelectButton.addTarget(self, action: #selector(businessSelectButtonTapped), for: .touchUpInside)
        //     myInfoButton.addTarget(self, action: #selector(myInfoButtonTapped), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        inquryButton.addTarget(self, action: #selector(inquryButtonTapped), for: .touchUpInside)
        noticeListButton.addTarget(self, action: #selector(noticeListButtonTapped), for: .touchUpInside)
        facilityInfoSelectButton.addTarget(self, action: #selector(facilityInfoSelectButtonTapped), for: .touchUpInside)
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
    
    @objc func busSelectButtonTapped() {
        let busDetailViewController = BusDetailViewController(selectedPage: (0, .shuttleBus))
        busDetailViewController.title = "버스/교통"
        navigationController?.pushViewController(busDetailViewController, animated: true)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.hamburger, .click, "버스"))
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
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, diningLikeUseCase: diningLikeUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase)
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
        [backButton,nicknameLabel, greetingLabel, servicePaddingLabel, serviceGuideLabel, shopSelectButton, busSelectButton, diningSelectButton, landSelectButton, businessSelectButton, logOutButton, makeLoginDescription, settingButton, inquryButton, noticeListButton, facilityInfoSelectButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpDetailLayout() {
        let kindOfButton = [noticeListButton, shopSelectButton, busSelectButton, diningSelectButton, facilityInfoSelectButton, landSelectButton, businessSelectButton]
        let buttonName = ["공지사항", "주변 상점", "버스/교통", "식단", "교내 시설물 정보", "복덕방", "코인 for Business"]
        for idx in 0...6 {
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
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalTo(view.snp.leading).offset(10)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        settingButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.trailing.equalTo(view.snp.trailing).offset(-10)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        makeLoginDescription.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).offset(24)
        }
        greetingLabel.snp.makeConstraints { make in
            make.bottom.equalTo(nicknameLabel.snp.bottom)
            make.leading.equalTo(nicknameLabel.snp.trailing)
        }
        logOutButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(33.5)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(17)
            make.width.equalTo(60)
        }
        servicePaddingLabel.snp.makeConstraints { make in
            make.top.equalTo(settingButton.snp.bottom).offset(128)
            make.leading.equalTo(view.snp.leading)
            make.width.equalTo(24)
            make.height.equalTo(33)
        }
        serviceGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(settingButton.snp.bottom).offset(128)
            make.leading.equalTo(servicePaddingLabel.snp.trailing)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(33)
        }
        noticeListButton.snp.makeConstraints { make in
            make.top.equalTo(serviceGuideLabel.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(58)
        }
        shopSelectButton.snp.makeConstraints { make in
            make.top.equalTo(noticeListButton.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(58)
        }
        busSelectButton.snp.makeConstraints { make in
            make.top.equalTo(shopSelectButton.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(58)
        }
        diningSelectButton.snp.makeConstraints { make in
            make.top.equalTo(busSelectButton.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(58)
        }
        facilityInfoSelectButton.snp.makeConstraints { make in
            make.top.equalTo(diningSelectButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
        }
        landSelectButton.snp.makeConstraints { make in
            make.top.equalTo(facilityInfoSelectButton.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(58)
        }
        businessSelectButton.snp.makeConstraints { make in
            make.top.equalTo(landSelectButton.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(58)
        }
        inquryButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(24)
            make.bottom.equalTo(view.snp.bottom).offset(-30)
            make.width.equalTo(56)
            make.height.equalTo(26)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpDetailLayout()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
