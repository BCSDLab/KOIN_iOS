//
//  HomeViewController.swift
//  Koin
//
//  Created by 김나훈 on 1/15/24.
//

import Combine
import UIKit

final class HomeViewController: UIViewController, CollectionViewDelegate {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private let inputSubject: PassthroughSubject<HomeViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private let refreshControl = UIRefreshControl()
    private var isSegmentedControlSetupDone = false
    
    // MARK: - UI Components
    
    private let wrapperView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let grayColorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral50)
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let logoView: LogoView = {
        let logoView = LogoView(frame: .zero)
        return logoView
    }()
    
    private let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.appImage(asset: .logo)
        return imageView
    }()
    
    private let busLabel: UILabel = {
        let label = UILabel()
        label.text = "버스/교통"
        label.textColor = UIColor.appColor(.primary500)
        label.font = UIFont.appFont(.pretendardBold, size: 15)
        return label
    }()
    
    private let busCollectionView: BusCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - 120
        flowLayout.itemSize = CGSize(width: width, height: 175)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 8
        let collectionView = BusCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    private let shopLabel: UILabel = {
        let label = UILabel()
        label.text = "주변상점"
        label.textColor = UIColor.appColor(.primary500)
        label.font = UIFont.appFont(.pretendardBold, size: 15)
        return label
    }()
    
    private let shopCollectionView: ShopCollectionView = {
        let shopCollectionViewFlowLayout = UICollectionViewFlowLayout()
        shopCollectionViewFlowLayout.itemSize = CGSize(width: 45, height: 90)
        shopCollectionViewFlowLayout.scrollDirection = .horizontal
        shopCollectionViewFlowLayout.minimumLineSpacing = 8
        let shopCollectionView = ShopCollectionView(frame: .zero, collectionViewLayout: shopCollectionViewFlowLayout)
        return shopCollectionView
    }()
    
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.text = "식단"
        label.textColor = UIColor.appColor(.primary500)
        label.font = UIFont.appFont(.pretendardBold, size: 15)
        return label
    }()
    
    private let diningTooltipImageView: CancelableImageView = {
        let imageView = CancelableImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    private let cornerSegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segment.insertSegment(withTitle: "A코너", at: 0, animated: true)
        segment.insertSegment(withTitle: "B코너", at: 1, animated: true)
        segment.insertSegment(withTitle: "C코너", at: 2, animated: true)
        segment.insertSegment(withTitle: "능수관", at: 3, animated: true)
        segment.selectedSegmentIndex = 0
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500), NSAttributedString.Key.font: UIFont.appFont(.pretendardMedium, size: 14)], for: .normal)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary500), NSAttributedString.Key.font: UIFont.appFont(.pretendardMedium, size: 14)], for: .selected)
        return segment
    }()
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.primary500)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let menuBackgroundView: MenuBackgroundView = {
        let menuBackgroundView = MenuBackgroundView(frame: .zero)
        return menuBackgroundView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: HomeViewModel) {
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
        inputSubject.send(.viewDidLoad)
        inputSubject.send(.getBusInfo("koreatech", "terminal", "shuttle"))
        configureView()
        shopCollectionView.storeDelegate = self
        configureTapGesture()
        configureSwipeGestures()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        cornerSegmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        checkAndShowTooltip()
        print(KeyChainWorker.shared.read(key: .access) ?? "")
        print(KeyChainWorker.shared.read(key: .refresh) ?? "")
        print("위가 엑세스 아래가 리프레시")
    }
    
    @objc private func appWillEnterForeground() {
        if let centerIndexPath = busCollectionView.centerCellIndex,
           let cell = busCollectionView.cellForItem(at: centerIndexPath) as? BusCollectionViewCell {
            let busInfo = cell.getBusType()
            inputSubject.send(.getBusInfo(busInfo[0], busInfo[1], busInfo[2]))
        }
        
        inputSubject.send(.categorySelected(getDiningPlace()))
        inputSubject.send(.getUserScreenAction(Date(), .enterForeground))
    }
    
    @objc private func appDidEnterBackground() {
        inputSubject.send(.getUserScreenAction(Date(), .enterBackground))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let centerIndexPath = busCollectionView.centerCellIndex,
           let cell = busCollectionView.cellForItem(at: centerIndexPath) as? BusCollectionViewCell {
            let busInfo = cell.getBusType()
            inputSubject.send(.getBusInfo(busInfo[0], busInfo[1], busInfo[2]))
        } else {
            inputSubject.send(.getBusInfo("koreatech", "terminal", "shuttle"))
        }
        inputSubject.send(.getUserScreenAction(Date(), .enterVC))
        inputSubject.send(.categorySelected(getDiningPlace()))
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSegmentedControlUnderline()
        if !isSegmentedControlSetupDone {
            setupSegmentedControlUnderline()
            isSegmentedControlSetupDone = true
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateDining(diningItem, diningType):
                self?.updateDining(item: diningItem, type: diningType)
            case let .putImage(response):
                self?.putImage(data: response)
            case let .updateBus(response):
                self?.updateBusTime(response)
            case .moveBusItem:
                self?.scrollToBusItem()
            }
        }.store(in: &subscriptions)
        
        
        busCollectionView.busRequestPublisher
            .sink { [weak self] data in
                self?.inputSubject.send(.getBusInfo(data[0], data[1], data[2]))
                
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainBusChangeToFrom, .click, data[3]))
            }
            .store(in: &subscriptions)
        
        busCollectionView.busTypePublisher
            .sink { [weak self] busType in
                self?.redirectByBusCardBtn(busType: busType)
            }.store(in: &subscriptions)
        
        logoView.lineButtonPublisher.sink { [weak self] in
            self?.navigateToServiceSelectViewController()
            
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.User.hamburger, .click, "햄버거"))
        }.store(in: &subscriptions)
        
        busCollectionView.scrollPublisheer.sink { [weak self] item in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainBusScroll, .scroll, item))
        }.store(in: &subscriptions)
        
        diningTooltipImageView.onImageTapped = { [weak self] in
            self?.navigatetoDining()
        }
        
        diningTooltipImageView.onXButtonTapped = { [weak self] in
            self?.diningTooltipImageView.isHidden = true
        }
    }
}

extension HomeViewController {
    
    private func checkAndShowTooltip() {
        let hasShownImage = UserDefaults.standard.bool(forKey: "hasShownTooltip")
        
        if !hasShownImage {
            diningTooltipImageView.isHidden = false
            UserDefaults.standard.set(true, forKey: "hasShownTooltip")
        }
    }
    
    @objc private func segmentDidChange(_ sender: UISegmentedControl) {
        inputSubject.send(.categorySelected(getDiningPlace()))
        
        let underlineFinalXPosition = (sender.bounds.width / CGFloat(sender.numberOfSegments)) *  CGFloat(sender.selectedSegmentIndex)
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.underlineView.frame.origin.x = underlineFinalXPosition
            }
        )
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainMenuCorner, .click, getDiningPlace().rawValue))
    }
    
    private func redirectByBusCardBtn(busType: BusType) {
        switch busType {
        case .shuttleBus:
            if let url = URL(string: "https://koreatech.unibus.kr"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .expressBus:
            let movingPage = BusDetailViewController(selectedPage: (2, .expressBus))
            movingPage.title = "버스/교통"
            self.navigationController?.pushViewController(movingPage, animated: true)
        default:
            let movingPage = BusDetailViewController(selectedPage: (2, .cityBus))
            movingPage.title = "버스/교통"
            self.navigationController?.pushViewController(movingPage, animated: true)
        }
    }
    
    private func navigateToServiceSelectViewController() {
        let serviceSelectViewController = ServiceSelectViewController(viewModel: ServiceSelectViewModel(fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), sendDeviceTokenUseCase: DefaultSendDeviceTokenUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))))
        navigationController?.pushViewController(serviceSelectViewController, animated: true)
    }
    
    private func scrollToBusItem() {
        let initialIndexPath = IndexPath(item: 4, section: 0)
        busCollectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: false)
        inputSubject.send(.getBusInfo("koreatech", "terminal", "shuttle"))
    }
    
    private func updateBusTime(_ data: BusDTO) {
        busCollectionView.updateText(data: data)
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuViewTapped))
        menuBackgroundView.addGestureRecognizer(tapGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(busViewTapped))
        busCollectionView.addGestureRecognizer(tapGesture2)
        
    }
    
    private func configureSwipeGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        menuBackgroundView.addGestureRecognizer(swipeLeftGesture)
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        menuBackgroundView.addGestureRecognizer(swipeRightGesture)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let currentSegmentIndex = cornerSegmentControl.selectedSegmentIndex
        if gesture.direction == .left {
            if currentSegmentIndex < cornerSegmentControl.numberOfSegments - 1 {
                cornerSegmentControl.selectedSegmentIndex = currentSegmentIndex + 1
            }
        } else if gesture.direction == .right {
            if currentSegmentIndex > 0 {
                cornerSegmentControl.selectedSegmentIndex = currentSegmentIndex - 1
            }
        }
        segmentDidChange(cornerSegmentControl)
    }
    
    @objc private func menuViewTapped() {
        navigatetoDining()
    }
    
    private func navigatetoDining() {
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
        let sendDeviceTokenUseCase = DefaultSendDeviceTokenUseCase(notiRepository: notiRepository)
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, diningLikeUseCase: diningLikeUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase, sendDeviceTokenUseCase: sendDeviceTokenUseCase)
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"
        navigationController?.pushViewController(diningViewController, animated: true)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainMenuMoveDetailView, .click, "식단"))
    }
    
    @objc private func busViewTapped() {
        let busViewController = BusDetailViewController(selectedPage: (0, .shuttleBus))
        busViewController.title = "버스/교통"
        navigationController?.pushViewController(busViewController, animated: true)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainBus, .click, "버스"))
    }
    
    private func updateDining(item: DiningItem?, type: DiningType) {
        menuBackgroundView.updateDining(item, type)
    }
    
    private func putImage(data: ShopCategoryDTO) {
        shopCollectionView.updateCategories(data.shopCategories)
    }
    
    func didTapCell(at id: Int) {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        
        let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
        let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let searchShopUseCase = DefaultSearchShopUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        
        let viewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            searchShopUseCase: searchShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            selectedId: id
        )
        let shopViewController = ShopViewController(viewModel: viewModel)
        shopViewController.title = "주변상점"
        navigationController?.pushViewController(shopViewController, animated: true)
        
        let category = MakeParamsForLog().makeValueForLogAboutStoreId(id: id)
        inputSubject.send(.getUserScreenAction(Date(), .leaveVC, .mainShopCategories))
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.mainShopCategories, .click, category, "메인", category, .leaveVC, .mainShopCategories))
    }
    
    @objc private func refresh() {
        if let centerIndexPath = busCollectionView.centerCellIndex,
           let cell = busCollectionView.cellForItem(at: centerIndexPath) as? BusCollectionViewCell {
            let busInfo = cell.getBusType()
            inputSubject.send(.getBusInfo(busInfo[0], busInfo[1], busInfo[2]))
        }
        
        inputSubject.send(.categorySelected(getDiningPlace()))
        
        refreshControl.endRefreshing()
    }
    
}

extension HomeViewController {
    
    private func getDiningPlace() -> DiningPlace {
        switch cornerSegmentControl.selectedSegmentIndex {
        case 0: return .cornerA
        case 1: return .cornerB
        case 2: return .cornerC
        default: return .special
        }
    }
}


extension HomeViewController {
    
    private func setUpNavigationBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    private func setUpLayOuts() {
        
        [wrapperView, logoView].forEach {
            view.addSubview($0)
        }
        wrapperView.addSubview(scrollView)
        [busLabel, diningTooltipImageView, busCollectionView, shopLabel, shopCollectionView, menuLabel, menuBackgroundView, tabBarView, grayColorView].forEach {
            scrollView.addSubview($0)
        }
        
        [cornerSegmentControl].forEach {
            tabBarView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        wrapperView.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        logoView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(119)
            make.centerX.equalTo(view.snp.centerX)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(wrapperView.snp.top)
            make.leading.equalTo(wrapperView.snp.leading)
            make.trailing.equalTo(wrapperView.snp.trailing)
            make.bottom.equalTo(wrapperView.snp.bottom)
        }
        busLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(40)
            make.height.equalTo(22)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        busCollectionView.snp.makeConstraints { make in
            make.top.equalTo(busLabel.snp.bottom).offset(11)
            make.width.equalTo(scrollView.snp.width)
            make.height.equalTo(185)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        shopLabel.snp.makeConstraints { make in
            make.top.equalTo(busCollectionView.snp.bottom).offset(40)
            make.height.equalTo(22)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        shopCollectionView.snp.makeConstraints { make in
            make.top.equalTo(shopLabel.snp.bottom).offset(11)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-20)
            make.height.equalTo(70)
        }
        menuLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.top.equalTo(shopCollectionView.snp.bottom).offset(40)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
        }
        diningTooltipImageView.snp.makeConstraints { make in
            make.centerY.equalTo(menuLabel.snp.centerY)
            make.leading.equalTo(menuLabel.snp.trailing).offset(8)
            make.width.equalTo(176)
            make.height.equalTo(36)
        }
        menuBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(cornerSegmentControl.snp.bottom)
            make.height.equalTo(233)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-11)
        }
        tabBarView.snp.makeConstraints {
            $0.top.equalTo(menuLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(45)
            $0.width.equalTo(264)
        }
        cornerSegmentControl.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(43)
        }
    }
    private func setUpRoundedCorners() {
        logoView.layer.cornerRadius = 20
        logoView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        logoView.clipsToBounds = true
    }
    
    private func setUpShadow() {
        logoView.layer.masksToBounds = false
        logoView.layer.shadowColor = UIColor.black.cgColor
        logoView.layer.shadowOpacity = 0.5
        logoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoView.layer.shadowRadius = 4
    }
    
    private func configureView() {
        setUpNavigationBar()
        setUpLayOuts()
        setUpConstraints()
        setUpShadow()
        setUpRoundedCorners()
        scrollView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        self.view.backgroundColor = .systemBackground
    }
    
    private func setupSegmentedControlUnderline() {
        
        let segmentControl = cornerSegmentControl
        let numberOfSegments = CGFloat(segmentControl.numberOfSegments)
        let underlineWidth = segmentControl.bounds.size.width / numberOfSegments
        let underlineHeight: CGFloat = 2
        let underlineXPosition = underlineWidth * CGFloat(segmentControl.selectedSegmentIndex)
        let underlineYPosition = segmentControl.bounds.size.height - underlineHeight
        
        underlineView.frame = CGRect(x: underlineXPosition, y: underlineYPosition, width: underlineWidth, height: underlineHeight)
        
        tabBarView.addSubview(underlineView)
    }
}


