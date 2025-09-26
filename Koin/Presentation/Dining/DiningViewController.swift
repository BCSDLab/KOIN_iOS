//
//  DiningViewController.swift
//  Koin
//
//  Created by 김나훈 on 3/14/24.
//

import Combine
import UIKit

final class DiningViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: DiningViewModel
    private let inputSubject: PassthroughSubject<DiningViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private let refreshControl = UIRefreshControl()
    private var viewDidAppeared = false
    
    // FIXME: - AB 테스트 식단 세션 아이디 프로퍼티
    
    private var customSessionId: String?
    
    // MARK: - UI Components
    
    private let dateCalendarCollectionView: CalendarCollectionView = {
        let flowLayout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumLineSpacing = (UIScreen.main.bounds.width - (28 * 7 + 24 * 2)) / 6
            $0.itemSize = .init(width: 28, height: 52)
        }
        
        return CalendarCollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
            $0.isScrollEnabled = false
        }
    }()
    
    private let diningTypeSegmentControl = UISegmentedControl().then {
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        $0.insertSegment(withTitle: "아침", at: 0, animated: true)
        $0.insertSegment(withTitle: "점심", at: 1, animated: true)
        $0.insertSegment(withTitle: "저녁", at: 2, animated: true)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500), NSAttributedString.Key.font: UIFont.appFont(.pretendardMedium, size: 16)], for: .normal)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary500), NSAttributedString.Key.font: UIFont.appFont(.pretendardBold, size: 16)], for: .selected)
    }
    
    private lazy var underlineView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
    }
    
    private let separateViewArray: [UIView] = {
        var viewArray: [UIView] = []
        for _ in 0..<3 {
            let view = UIView()
            view.backgroundColor = UIColor.appColor(.neutral400)
            viewArray.append(view)
        }
        return viewArray
    }()
    
    private let stackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.02, x: 0, y: 1, blur: 1, spread: 0)
    }
    
    private let diningListCollectionView: DiningCollectionView = {
        let flowLayout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
        }
                
        return DiningCollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
            $0.backgroundColor = .appColor(.neutral200)
        }
    }()
    
    private let warningImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .warning)
    }
    
    private lazy var tabBarView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let warningLabel = UILabel().then {
        $0.text = "식단이 표시되지 않아\n표시할 수 없습니다."
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let diningNotiContentViewController = DiningNotiContentViewController()
    
    private let diningLikeLoginModalViewController = ModalViewController(width: 301, height: 230, paddingBetweenLabels: 8, title: "더 맛있는 학식을 먹는 방법,\n로그인하고 좋아요를 남겨주세요!", subTitle: "여러분의 좋아요가 영양사님이 더 나은,\n식단을 제공할 수 있도록 도와줍니다.", titleColor: .appColor(.neutral700), subTitleColor: .appColor(.gray)).then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private func configureSwipeGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        diningListCollectionView.addGestureRecognizer(swipeLeftGesture)
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        diningListCollectionView.addGestureRecognizer(swipeRightGesture)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let currentSegmentIndex = diningTypeSegmentControl.selectedSegmentIndex
        if gesture.direction == .left {
            if currentSegmentIndex < diningTypeSegmentControl.numberOfSegments - 1 {
                diningTypeSegmentControl.selectedSegmentIndex = currentSegmentIndex + 1
            }
        } else if gesture.direction == .right {
            if currentSegmentIndex > 0 {
                diningTypeSegmentControl.selectedSegmentIndex = currentSegmentIndex - 1
            }
        }
        segmentDidChange(diningTypeSegmentControl)
    }
    
    private let diningToShopAbTestButton = DiningToShopAbTestButton().then {
        $0.isHidden = true
    }
    
    // MARK: - Initialization
    
    init(viewModel: DiningViewModel) {
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
        configureSwipeGestures()
        configureView()
        navigationItem.title = "식단"
        inputSubject.send(.getAbTestResult)
        inputSubject.send(.determineInitDate)
        diningTypeSegmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        diningListCollectionView.refreshControl = refreshControl
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.appImage(asset: .coopInfo), style: .plain, target: self, action: #selector(navigationButtonTapped))
        
        diningToShopAbTestButton.addTarget(self, action: #selector(didTapDiningToShop), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .fill)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkAndShowBottomSheet()
        if viewDidAppeared {
            switch diningTypeSegmentControl.selectedSegmentIndex {
            case 0: inputSubject.send(.updateDisplayDateTime(nil, .breakfast))
            case 1: inputSubject.send(.updateDisplayDateTime(nil, .lunch))
            default: inputSubject.send(.updateDisplayDateTime(nil, .dinner))
            }
        }
        viewDidAppeared = true
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case let .updateDiningList(list, diningType):
                self?.setDiningList(list)
                self?.moveUnderLineView(diningType: diningType)
            case let .initCalendar(showingDate):
                self?.dateCalendarCollectionView.generateDateList(showingDate: showingDate)
            case let .showBottomSheet((soldOutIsOn, imageUplloadisOn)):
                self?.showBottomSheet((soldOutIsOn, imageUplloadisOn))
                UserDefaults.standard.set(true, forKey: "hasShownBottomSheet")
            case .showLoginModal:
                self?.present(strongSelf.diningLikeLoginModalViewController, animated: true, completion: nil)
            case let .setAbTestResult(abTestResult):
                self?.handleAbTestResult(abTestResult)
            }
        }.store(in: &subscriptions)
        
        dateCalendarCollectionView.dateTapPublisher.sink { [weak self] date in
            self?.inputSubject.send(.updateDisplayDateTime(date, nil))
        }.store(in: &subscriptions)
        
        diningListCollectionView.imageTapPublisher.sink { [weak self] tuple in
            guard let self = self else { return }
            let tappedDiningImage = tuple.0
            let tappedPlaceText = tuple.1
            
            let imageWidth: CGFloat = UIScreen.main.bounds.width - 48
            let smallProportion: CGFloat = tappedDiningImage.size.width / imageWidth
            let imageHeight: CGFloat = tappedDiningImage.size.height / smallProportion
            let zoomedImageViewController = ZoomedImageViewController(imageWidth: imageWidth, imageHeight: imageHeight.isNaN ? 100 : imageHeight)
            zoomedImageViewController.setImage(tappedDiningImage)
            self.present(zoomedImageViewController, animated: true, completion: nil)
            
            inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.menuImage, .click, "\(self.getCurrentDiningType())_\(tappedPlaceText)"))
            
        }.store(in: &subscriptions)
        
        diningListCollectionView.shareButtonPublisher.sink { [weak self] item in
            self?.inputSubject.send(.shareMenuList(item))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.menuShare, .click, "공유하기"))
        }.store(in: &subscriptions)
        
        diningListCollectionView.logScrollPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.menuTime, .scroll, self.getCurrentDiningType()))
        }.store(in: &subscriptions)
        
        diningNotiContentViewController.soldOutSwitchPublisher.sink { [weak self] isOn in
            self?.inputSubject.send(.changeNoti(isOn, .diningSoldOut))
        }.store(in: &subscriptions)
        
        diningNotiContentViewController.imageUploadSwitchPublisher.sink { [weak self] isOn in
            self?.inputSubject.send(.changeNoti(isOn, .diningImageUpload))
        }.store(in: &subscriptions)
        
        diningNotiContentViewController.shortcutButtonPublisher.sink { [weak self] in
            self?.navigateToNoti()
            self?.diningNotiContentViewController.dissmissView()
        }.store(in: &subscriptions)
        
        diningLikeLoginModalViewController.rightButtonPublisher.sink { [weak self] in
            self?.navigateToLogin()
        }.store(in: &subscriptions)
        
    }
}

// MARK: - Dining To Shop AB Test
extension DiningViewController {
    private func handleAbTestResult(_ abTestResult: AssignAbTestResponse) {
        switch abTestResult.variableName {
        case .variant:
            diningToShopAbTestButton.isHidden = false
            logAbTestResult(value: "design_B")
        case .control:
            diningToShopAbTestButton.isHidden = true
            logAbTestResult(value: "design_A")
        default:
            break
        }
    }

    private func logAbTestResult(value: String) {
        let loginFlag = (UserDefaults.standard.object(forKey: "loginFlag") as? Int) ?? 0

        let customSessionId = CustomSessionManager.getOrCreateSessionId(duration: .thirtyMinutes, eventName: "dining2shop", loginStatus: loginFlag, platform: "iOS")
        
        self.customSessionId = customSessionId
        
        inputSubject.send(.logEventWithSessionId(EventParameter.EventLabel.AbTest.dining2shop1, .abTestDiningEntry, value, customSessionId))
    }
    
    @objc private func didTapDiningToShop() {
        let loginFlag = (UserDefaults.standard.object(forKey: "loginFlag") as? Int) ?? 0
        let customSessionId = customSessionId ?? CustomSessionManager.current(eventName: "dining2shop")
                                              ?? CustomSessionManager.getOrCreateSessionId(duration: .thirtyMinutes, eventName: "dining2shop", loginStatus: loginFlag, platform: "iOS")
        inputSubject.send(.logEventWithSessionId(EventParameter.EventLabel.AbTest.diningToShop, .click, getCurrentDiningType(), customSessionId))
        
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
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            searchShopUseCase: searchShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            selectedId: 1
        )

        let shopViewController = ShopViewControllerA(viewModel: viewModel)
        shopViewController.title = "주변상점"
        navigationController?.pushViewController(shopViewController, animated: true)
    }
}

extension DiningViewController {
    @objc private func refresh() {
        switch diningTypeSegmentControl.selectedSegmentIndex {
        case 0: inputSubject.send(.updateDisplayDateTime(nil, .breakfast))
        case 1: inputSubject.send(.updateDisplayDateTime(nil, .lunch))
        default: inputSubject.send(.updateDisplayDateTime(nil, .dinner))
        }
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.menuTime, .click, getCurrentDiningType()))
        
        refreshControl.endRefreshing()
    }
    
    private func checkAndShowBottomSheet() {
        let hasShownImage = UserDefaults.standard.bool(forKey: "hasShownBottomSheet")
        
        if !hasShownImage {
            inputSubject.send(.fetchNotiList)
        }
    }
    
    private func navigateToNoti() {
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let notiViewController = NotiViewController(viewModel: NotiViewModel(changeNotiUseCase: changeNotiUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase, fetchNotiListUseCase: fetchNotiListUseCase, logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
            notiViewController.title = "알림설정"
        navigationController?.pushViewController(notiViewController, animated: true)
    }
    
    private func showBottomSheet(_ isOn: (Bool, Bool)) {
      
        let bottomSheetViewController = BottomSheetViewController(contentViewController: diningNotiContentViewController, defaultHeight: 332, cornerRadius: 16, dimmedAlpha: 0.4, isPannedable: false)
        diningNotiContentViewController.updateButtonIsOn(isOn)
        self.present(bottomSheetViewController, animated: true)
    }
    
    @objc private func navigationButtonTapped() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.cafeteriaInfo, .click, "학생식당정보"))
        let diningNoticeViewController = DiningNoticeViewController(viewModel: DiningNoticeViewModel(fetchCoopShopListUseCase: DefaultFetchCoopShopListUseCase(diningRepository: DefaultDiningRepository(diningService: DefaultDiningService(), shareService: KakaoShareService()))))
        diningNoticeViewController.title = "학생식당 정보"
        navigationController?.pushViewController(diningNoticeViewController, animated: true)
    }
    
    @objc private func segmentDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: inputSubject.send(.updateDisplayDateTime(nil, .breakfast))
        case 1: inputSubject.send(.updateDisplayDateTime(nil, .lunch))
        default: inputSubject.send(.updateDisplayDateTime(nil, .dinner))
        }
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.menuTime, .click, getCurrentDiningType()))
    }
    
    private func moveUnderLineView(diningType: DiningType) {
        let selectedIndex: Int
        
        switch diningType {
        case .breakfast: selectedIndex = 0
        case .lunch: selectedIndex = 1
        case .dinner: selectedIndex = 2
        }
        
        let segment = diningTypeSegmentControl
        self.diningTypeSegmentControl.selectedSegmentIndex = selectedIndex
        let underlineFinalXPosition = (segment.bounds.width / CGFloat(segment.numberOfSegments)) * CGFloat(selectedIndex)
        
        UIView.animate (
            withDuration: 0.2,
            animations: { [weak self] in
                guard let self = self
                else { return }
                self.underlineView.frame.origin.x = underlineFinalXPosition
            }
        )
    }
    
    private func hideImageIfEmpty(_ hide: Bool) {
        if !hide {
            warningLabel.isHidden = true
            warningImageView.isHidden = true
        }
        else {
            warningLabel.isHidden = false
            warningImageView.isHidden = false
        }
    }
    
    private func setDiningList(_ list: [DiningItem]) {
        hideImageIfEmpty(list.isEmpty)
        diningListCollectionView.setDiningList(list)
    }
    
    private func getCurrentDiningType() -> String {
        switch diningTypeSegmentControl.selectedSegmentIndex {
        case 0: return "아침"
        case 1: return "점심"
        default: return "저녁"
        }
    }
}

extension DiningViewController {
    
    private func setUpLayOuts() {
        [dateCalendarCollectionView, diningListCollectionView, warningLabel, warningImageView, stackView, tabBarView, diningToShopAbTestButton].forEach {
            view.addSubview($0)
        }

        [diningTypeSegmentControl, underlineView].forEach {
            tabBarView.addSubview($0)
        }
        
        separateViewArray.forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setUpConstraints() {
        tabBarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(dateCalendarCollectionView.snp.bottom)
            $0.height.equalTo(45)
        }
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(tabBarView.snp.bottom)
            $0.height.equalTo(1)
        }
        warningImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(52)
            $0.width.equalTo(52)
        }
        warningLabel.snp.makeConstraints {
            $0.top.equalTo(warningImageView.snp.bottom).offset(8.28)
            $0.centerX.equalToSuperview()
        }
        dateCalendarCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(24)
            $0.trailing.equalTo(24)
            $0.height.equalTo(99)
        }
        diningTypeSegmentControl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(43)
        }
        underlineView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().dividedBy(diningTypeSegmentControl.numberOfSegments)
            $0.top.equalTo(diningTypeSegmentControl.snp.bottom)
            $0.height.equalTo(2)
        }
        diningListCollectionView.snp.makeConstraints {
            $0.top.equalTo(tabBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        diningToShopAbTestButton.snp.makeConstraints() {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-8)
            $0.height.equalTo(46)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = .systemBackground
    }
}
