//
//  LoginViewController.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Combine
import SafariServices
import UIKit
import SnapKit

final class LoginViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: LoginViewModel
    private let inputSubject: PassthroughSubject<LoginViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()

    private let contentTopPaddingLayoutGuide = UILayoutGuide()
    private let contentLayoutGuide = UILayoutGuide()
    private let contentBottomPaddingLayoutGuide = UILayoutGuide()
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .bcsdSymbolLogo)
        $0.contentMode = .scaleAspectFit
    }

    private let logoTextImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .koinTextLogo)
        $0.contentMode = .scaleAspectFit
    }
    
    private let idTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "아이디(Koreatech ID/전화번호)",
            attributes: [
                .foregroundColor: UIColor.appColor(.neutral400),
                .font: UIFont.appFont(.pretendardRegular, size: 16)
            ]
        )
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.textContentType = .username
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
    }
    
    private let separateView1 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let idWarningLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.new800)
    }
    
    private let passwordTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "비밀번호",
            attributes: [
                .foregroundColor: UIColor.appColor(.neutral400),
                .font: UIFont.appFont(.pretendardRegular, size: 16)
            ]
        )
        $0.textContentType = .password
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
        $0.isSecureTextEntry = true
    }
    
    private let changeSecureButton = UIButton().then { button in
        button.setImage(UIImage.appImage(asset: .visibility), for: .normal)
        button.accessibilityLabel = "비밀번호 보기"
    }
    
    private let separateView2 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let passwordWarningLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.new800)
    }
    
    private let warningImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .warningOrange)?.withRenderingMode(.alwaysTemplate).withTintColor(.appColor(.new800))
        $0.isHidden = true
    }
    
    private let loginButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.new500)
        $0.setTitle("로그인", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.layer.cornerRadius = 8
    }
    
    private let registerButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(UIColor.appColor(.new500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.layer.borderColor = UIColor.appColor(.new500).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }
    
    private let findButtonsLayoutGuide = UILayoutGuide()
    
    private let findIdButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .findId)
        var text = AttributedString("아이디 찾기")
        text.font = UIFont.appFont(.pretendardRegular, size: 12)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.contentInsets = .zero
        configuration.baseForegroundColor = UIColor.appColor(.neutral500)
        $0.configuration = configuration
    }
    
    private let findSeparatorLabel = UILabel().then {
        $0.text = "|"
        $0.textColor = .appColor(.neutral500)
        $0.font = .appFont(.pretendardRegular, size: 15)
    }
    
    private let findPasswordButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .findPassword)
        var text = AttributedString("비밀번호 찾기")
        text.font = UIFont.appFont(.pretendardRegular, size: 12)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.contentInsets = .zero
        configuration.baseForegroundColor = UIColor.appColor(.neutral500)
        $0.configuration = configuration
    }
    
    private let footerLayoutGuide = UILayoutGuide()
    
    private let ownerButton = UIButton().then {
        $0.setTitle("사장님이신가요?", for: .normal)
        $0.setTitleColor(UIColor.appColor(.new500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let copyrightLabel = UILabel().then {
        $0.text = "Copyright @ BCSD Lab All rights reserved."
        $0.textColor = UIColor.appColor(.neutral600)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textAlignment = .center
    }
    
    // MARK: - Initialization
    init(viewModel: LoginViewModel) {
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
        title = "로그인"
        configureView()
        bind()
        hideKeyboardWhenTappedAround()
        changeSecureButton.addTarget(self, action: #selector(changeSecureButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        findPasswordButton.addTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
        ownerButton.addTarget(self, action: #selector(ownerButtonTapped), for: .touchUpInside)
        idTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configureNavigationBar(style: .empty
        )
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .showErrorMessage(message):
                self?.warningImageView.isHidden = false
                self?.passwordWarningLabel.text = message
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.User.login, .click, "로그인 실패"))
            case .loginSuccess:
                self?.navigationController?.popViewController(animated: true)
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.User.login, .click, "로그인 완료"))
            case .showForceModal:
                self?.navigationController?.setViewControllers([ForceModifyUserViewController()], animated: true)
            case .showModifyModal:
                self?.presentModifyUserModal()
            }
        }.store(in: &subscriptions)
    }
}

extension LoginViewController {
    private func presentModifyUserModal() {
        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .primary,
            content: .titles(
                mainTitleText: "아직 입력되지 않은 정보가 있어요.",
                mainTitleStyle: .init(
                    textColor: .neutral800,
                    font: .pretendardMedium,
                    fontSize: 18
                ),
                subTitleText: "필수 정보를 입력하시면 더 많은 기능을 이용하실 수 있어요.\n지금 입력하시겠어요?",
                subTitleStyle: .init(
                    textColor: .neutral500,
                    font: .pretendardRegular,
                    fontSize: 12
                )
            ),
            button: .buttons(
                leftButtonTitle: "나중에 하기",
                leftButtonAction: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                },
                rightButtonTitle: "지금 입력하기",
                rightButtonAction: { [weak self] in
                    self?.navigateToChangeMyProfile()
                }
            ),
            layout: .init(width: 342)
        ))
        present(modalViewController, animated: true)
    }

    private func navigateToChangeMyProfile() {
        let homeViewController = makeHomeTabBarController()
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let modifyUseCase = DefaultModifyUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let fetchDeptListUseCase = DefaultFetchDeptListUseCase(timetableRepository: DefaultTimetableRepository(service: DefaultTimetableService()))
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let checkDuplicatedNicknameUseCase = DefaultCheckDuplicatedNicknameUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let changeMyProfileViewController = ChangeMyProfileViewController(viewModel: ChangeMyProfileViewModel(modifyUseCase: modifyUseCase, fetchDeptListUseCase: fetchDeptListUseCase, fetchUserDataUseCase: fetchUserDataUseCase, checkDuplicatedNicknameUseCase: checkDuplicatedNicknameUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase), userType: .student)
        navigationController?.setViewControllers([homeViewController, changeMyProfileViewController], animated: true)
    }

    @objc private func changeSecureButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        changeSecureButton.setImage(passwordTextField.isSecureTextEntry ? UIImage.appImage(asset: .visibility) : UIImage.appImage(asset: .visibilityNon), for: .normal)
        changeSecureButton.accessibilityLabel = passwordTextField.isSecureTextEntry ? "비밀번호 보기" : "비밀번호 숨기기"
    }

    @objc private func findIdButtonTapped() {
        let viewController = FindPhoneIdViewController(viewModel: FindIdViewModel())
        navigationController?.pushViewController(viewController, animated: true)
        inputSubject.send(.logEvent(EventParameter.EventLabel.User.login, .click, "아이디 찾기"))
    }
    
    @objc private func findPasswordButtonTapped() {
        let findPasswordViewController = FindPasswordCertViewController(viewModel: FindPasswordViewModel())
        navigationController?.pushViewController(findPasswordViewController, animated: true)
        inputSubject.send(.logEvent(EventParameter.EventLabel.User.login, .click, "비밀번호 찾기"))
    }

    @objc private func ownerButtonTapped() {
        guard let url = URL(string: "https://owner.koreatech.in") else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
    
    @objc func loginButtonTapped() {
        warningImageView.isHidden = true
        idWarningLabel.text = ""
        passwordWarningLabel.text = ""
        inputSubject.send(.login(idTextField.text ?? "", passwordTextField.text ?? ""))
    }
    
    @objc func registerButtonTapped() {
        let timetableRepositoy = DefaultTimetableRepository(service: DefaultTimetableService())
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))

        let registerViewController = AgreementFormViewController(
            viewModel: RegisterFormViewModel(
                checkDuplicatedPhoneNumberUseCase: DefaultCheckDuplicatedPhoneNumberUseCase(
                    userRepository: userRepository
                ),
                sendVerificationCodeUseCase: DefaultSendVerificationCodeUseCase(
                    userRepository: userRepository
                ),
                checkVerificationCodeUseCase: DefaultCheckVerificationCodeUsecase(
                    userRepository: userRepository
                ),
                checkDuplicatedIdUseCase: DefaultCheckDuplicatedIdUsecase (
                    userRepository: userRepository
                ),
                fetchDeptListUseCase: DefaultFetchDeptListUseCase(
                    timetableRepository: timetableRepositoy
                ),
                checkDuplicatedNicknameUseCase: DefaultCheckDuplicatedNicknameUseCase (
                    userRepository: userRepository
                ),
                registerFormUseCase: DefaultRegisterFormUseCase(
                    userRepository: userRepository
                ),
                logAnalyticsEventUseCase: logAnalyticsEventUseCase
            )
        )
        registerViewController.title = "회원가입"
        navigationController?.pushViewController(registerViewController, animated: true)
        
        let customSessionId = CustomSessionManager.getOrCreateSessionId(duration: .fifteenMinutes, eventName: "sign_up", loginStatus: 0, platform: "iOS")
        inputSubject.send(.logSessionEvent(EventParameter.EventLabel.User.startSignUp, .click, "회원가입 시작", customSessionId))
    }
}

extension LoginViewController {
    
    private func setUpLayOuts() {
        [logoImageView, logoTextImageView,
         idTextField, separateView1, passwordTextField, changeSecureButton, separateView2,
         warningImageView, idWarningLabel, passwordWarningLabel,
         loginButton, registerButton,
         findIdButton, findSeparatorLabel, findPasswordButton,
         ownerButton, copyrightLabel].forEach {
            contentView.addSubview($0)
        }
        
        [contentTopPaddingLayoutGuide, contentLayoutGuide, contentBottomPaddingLayoutGuide, findButtonsLayoutGuide, footerLayoutGuide].forEach {
            contentView.addLayoutGuide($0)
        }
        
        [contentView].forEach {
            scrollView.addSubview($0)
        }
        
        [scrollView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
            $0.height.greaterThanOrEqualTo(view.safeAreaLayoutGuide)
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.centerX.equalTo(contentLayoutGuide)
            $0.height.equalTo(66)
        }
        logoTextImageView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(9)
            $0.centerX.equalTo(contentLayoutGuide)
            $0.width.equalTo(102)
            $0.height.equalTo(41)
        }
        idTextField.snp.makeConstraints {
            $0.top.equalTo(logoTextImageView.snp.bottom).offset(52)
            $0.leading.trailing.equalTo(contentLayoutGuide).inset(48)
            $0.height.equalTo(40)
        }
        separateView1.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom)
            make.leading.trailing.equalTo(contentLayoutGuide).inset(48)
            make.height.equalTo(1)
        }
        idWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView1.snp.bottom)
            make.leading.equalTo(idTextField.snp.leading)
            make.height.equalTo(20)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom).offset(24)
            make.leading.trailing.equalTo(contentLayoutGuide).inset(48)
            make.height.equalTo(40)
        }
        changeSecureButton.snp.makeConstraints { make in
            make.centerY.equalTo(passwordTextField.snp.centerY)
            make.trailing.equalTo(passwordTextField.snp.trailing).offset(12)
            make.width.height.equalTo(44)
        }
        separateView2.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom)
            make.leading.trailing.equalTo(contentLayoutGuide).inset(48)
            make.height.equalTo(1)
        }
        warningImageView.snp.makeConstraints { make in
            make.centerY.equalTo(passwordWarningLabel.snp.centerY)
            make.leading.equalTo(separateView2.snp.leading)
            make.width.height.equalTo(16)
        }
        passwordWarningLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView2.snp.bottom).offset(8)
            make.leading.equalTo(warningImageView.snp.trailing).offset(4)
            make.height.greaterThanOrEqualTo(20)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(separateView2.snp.bottom).offset(48)
            make.leading.trailing.equalTo(contentLayoutGuide).inset(48)
            make.height.equalTo(44)
        }
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(24)
            make.leading.trailing.equalTo(contentLayoutGuide).inset(48)
            make.height.equalTo(44)
        }
        
        findIdButton.snp.makeConstraints {
            $0.leading.equalTo(findButtonsLayoutGuide)
            $0.centerY.equalTo(findButtonsLayoutGuide)
        }
        findSeparatorLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(findButtonsLayoutGuide)
            $0.leading.equalTo(findIdButton.snp.trailing).offset(10)
        }
        findPasswordButton.snp.makeConstraints {
            $0.leading.equalTo(findSeparatorLabel.snp.trailing).offset(10)
            $0.trailing.equalTo(findButtonsLayoutGuide)
            $0.centerY.equalTo(findButtonsLayoutGuide)
        }
        findButtonsLayoutGuide.snp.makeConstraints {
            $0.centerX.bottom.equalTo(contentLayoutGuide)
            $0.top.equalTo(registerButton.snp.bottom).offset(32)
            $0.height.equalTo(22)
        }
        
        copyrightLabel.snp.makeConstraints {
            $0.bottom.centerX.equalTo(footerLayoutGuide)
            $0.height.equalTo(18)
        }
        ownerButton.snp.makeConstraints {
            $0.top.centerX.equalTo(footerLayoutGuide)
            $0.bottom.equalTo(copyrightLabel.snp.top).offset(-21)
            $0.height.equalTo(29)
        }
        
        contentTopPaddingLayoutGuide.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(contentBottomPaddingLayoutGuide.snp.height).multipliedBy(2.0/3.0)
        }
        contentLayoutGuide.snp.makeConstraints {
            $0.top.equalTo(contentTopPaddingLayoutGuide.snp.bottom)
            $0.bottom.equalTo(contentBottomPaddingLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        contentBottomPaddingLayoutGuide.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(footerLayoutGuide.snp.top)
            $0.height.greaterThanOrEqualTo(80)
        }
        footerLayoutGuide.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(0.5 < view.safeAreaInsets.bottom ? 0 : -32)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral0)
    }
}

extension LoginViewController {
    private func makeHomeTabBarController() -> HomeTabBarController {
        let homeViewController = makeHomeHostingController()
        let categoryViewController = makeCategoryHostingController()
        let noticeViewController = makeNoticeListViewController()
        let profileViewController = makeProfileHostingController()
        
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let checkHasUnreadNotificationHistoryUseCase = DefaultCheckHasUnreadNotificationHistoryUseCase(repository: DefaultNotificationHistoryRepository(service: DefaultNotificationHistoryService()))
        let viewModel = HomeTabBarViewModel(
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            checkHasUnreadNotificationHistoryUseCase: checkHasUnreadNotificationHistoryUseCase
        )

        return HomeTabBarController(
            items: [
                .init(viewController: homeViewController, tab: .home),
                .init(viewController: categoryViewController, tab: .category),
                .init(viewController: noticeViewController, tab: .board),
                .init(viewController: profileViewController, tab: .profile)
            ],
            viewModel: viewModel
        )
    }

    private func makeHomeHostingController() -> UIViewController {
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
        let fetchCountsUseCase = DefaultFetchHomeCountsUseCase(
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
        
        let viewModel = HomeViewModel(
            fetchHomeHeaderUseCase: fetchHomeHeaderUseCase,
            fetchHomeDiningListUseCase: fetchHomeDiningListUseCase,
            fetchCountsUseCase: fetchCountsUseCase,
            checkVersionUseCase: checkVersionUseCase,
            checkLoginUseCase: DefaultCheckLoginUseCase(userRepository: userRepository),
            fetchUserDataUseCase: fetchUserDataUseCase,
            sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            fetchBannerUseCase: DefaultFetchBannerUseCase(coreRepository: coreRepository)
        )
        let homeView = HomeView(viewModel: viewModel)
        return HomeHostingController(rootView: homeView)
    }
    
    private func makeCategoryHostingController() -> UIViewController {
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let categoryRootView = CategoryView(
            viewModel: CategoryViewModel(
                checkLoginUseCase: checkLoginUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase))
        return CategoryHostingController(rootView: categoryRootView)
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
    
    private func makeProfileHostingController() -> UIViewController {
        let timeTableRepository = DefaultTimetableRepository(service: DefaultTimetableService())
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let deleteDeviceTokenUseCase = DefaultDeleteDeviceTokenUseCase(repository: DefaultNotiRepository(service: DefaultNotiService()))
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let fetchMainFrameUseCase = DefaultFetchMainFrameUseCase(
            fetchFramesUseCase: DefaultFetchFramesUseCase(timetableRepository: timeTableRepository),
            fetchFrameUseCase: DefaultFetchFrameUseCase(timetableRepository: timeTableRepository),
            fetchLectureUseCase: DefaultFetchLectureUseCase(timetableRepository: timeTableRepository)
        )
        let profileViewModel = ProfileViewModel(
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            deleteDeviceTokenUseCase: deleteDeviceTokenUseCase,
            fetchUserDataUseCase: fetchUserDataUseCase,
            fetchMainFrameUseCase: fetchMainFrameUseCase
        )
        let profileView = ProfileView(viewModel: profileViewModel)
        return ProfileHostingController(rootView: profileView)
    }
}
