//
//  BusTimetableViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/03/30.
//

import Combine
import SnapKit
import Then
import UIKit

final class BusTimetableViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private var inputSubject: PassthroughSubject<BusTimetableViewModel.Input, Never> = .init()
    private let viewModel: BusTimetableViewModel
    private let busTypes: [BusType] = [.shuttleBus, .expressBus, .cityBus]
    private var selectedIndex = 0
    private var busStopTexts: [BusType: String] = [:]
    private var headerHeight: CGFloat = 48
    private let tabBarHeight: CGFloat = 50
    private var headerTopConstraint: Constraint?
    private var lastPageWidth: CGFloat = 0
    
    // MARK: - UI Components
    private let contentContainerView = UIView().then {
        $0.clipsToBounds = true
    }
    
    private let pagingScrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.bounces = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    private let pageStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    
    private let headerContainerView = UIView().then {
        $0.backgroundColor = .appColor(.neutral0)
    }
    
    private let timetableHeaderView = UIView()
    
    private let typeOftimetableLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 20)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.text = "셔틀버스 시간표"
    }
    
    private let busNoticeWrappedView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.cornerRadius = 8
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.08
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 2.5
        $0.isUserInteractionEnabled = true
        $0.isHidden = true
    }
    
    private let busNoticeLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.new500)
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let deleteNoticeButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .delete), for: .normal)
    }
    
    private let busTypeTabBarView = BusTimetableTabBarView(titles: ["셔틀", "대성", "시내"])
    
    private let shuttleRouteView = BusTimetableRouteView()
    
    private let expressRouteView = BusTimetableRouteView()
    
    private let cityRouteView = BusTimetableRouteView()
    
    private let shuttleTimetableTableView = ShuttleTimetableTableView(frame: .zero, style: .grouped)
    
    private let expressTimetableTableView = ExpressOrCityTimetableTableView(frame: .zero, style: .grouped)
    
    private let cityTimetableTableView = ExpressOrCityTimetableTableView(frame: .zero, style: .grouped)
    
    private let busStopImageView = UIImageView().then {
        $0.image = .appImage(asset: .busStop)
        $0.isHidden = true
    }
    
    private let busStopLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 13)
        $0.textColor = .appColor(.new500)
        $0.textAlignment = .right
        $0.isHidden = true
    }
    
    private var pageTableViews: [UITableView] {
        [shuttleTimetableTableView, expressTimetableTableView, cityTimetableTableView]
    }
    
    // MARK: - Initialization
    init(viewModel: BusTimetableViewModel) {
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
        deleteNoticeButton.addTarget(self, action: #selector(tapDeleteNoticeInfoButton), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapNoticeInfoButton))
        busNoticeWrappedView.addGestureRecognizer(tapGesture)
        pagingScrollView.delegate = self
        bind()
        busTypes.forEach { inputSubject.send(.getBusRoute($0)) }
        inputSubject.send(.getEmergencyNotice)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let pageWidth = pagingScrollView.bounds.width
        pageTableViews.forEach { updateBottomInset(of: $0) }
        busNoticeWrappedView.layer.shadowPath = UIBezierPath(roundedRect: busNoticeWrappedView.bounds, cornerRadius: 8).cgPath
        // 페이지 폭이 바뀐 경우(최초 레이아웃·회전)에만 보정한다. 탭 전환 애니메이션 중에 덮어쓰면 목표 페이지를 지나친다.
        guard pageWidth > 0, pageWidth != lastPageWidth else { return }
        lastPageWidth = pageWidth
        pagingScrollView.contentOffset.x = pageWidth * CGFloat(selectedIndex)
        busTypeTabBarView.updateIndicator(progress: CGFloat(selectedIndex))
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateBusRoute(busType: busType, firstBusRoute: firstBusRoute, secondBusRoute: secondBusRoute):
                self?.updateBusRoute(busType: busType, firstBusRoute: firstBusRoute, secondBusRoute: secondBusRoute)
            case let .updateBusTimetable(busType, busTimetableInfo):
                self?.updateBusTimetable(busType: busType, timetableInfo: busTimetableInfo)
            case let .updateShuttleBusRoutes(busRoutes: busRoutes):
                self?.updateShuttleBusRoutes(busRoutes: busRoutes)
            case let .updateEmergencyNotice(notice):
                self?.updateEmergencyNotice(notice: notice)
            case let .updateStopLabel(busType, busStop):
                self?.updateBusStopLabel(busType: busType, busStop: busStop)
            }
        }.store(in: &subscriptions)
        
        busTypeTabBarView.selectTabPublisher.sink { [weak self] index in
            self?.tapTab(index: index)
        }.store(in: &subscriptions)
        
        shuttleTimetableTableView.moveDetailTimetablePublisher.sink { [weak self] id, routeType, routeName in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.areaSpecificRoute, .click, "\(routeType.prefix(2))_\(routeName)"))
            let busRepository = DefaultBusRepository(service: DefaultBusService())
            let viewController = BusTimetableDataViewController(viewModel: BusTimetableDataViewModel(fetchShuttleTimetableUseCase: DefaultFetchShuttleBusTimetableUseCase(repository: busRepository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), shuttleRouteId: id))
            viewController.title = "\(routeName) 시간표"
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        bindRouteView(shuttleRouteView, busType: .shuttleBus)
        bindRouteView(expressRouteView, busType: .expressBus)
        bindRouteView(cityRouteView, busType: .cityBus)
        
        cityRouteView.secondFilterPublisher.sink { [weak self] busNumber in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.cityBusRoute, .click, busNumber))
        }.store(in: &subscriptions)
        
        shuttleTimetableTableView.tapIncorrectButtonPublisher.sink { [weak self] in
            self?.tapIncorrentInfoButton()
        }.store(in: &subscriptions)
        
        [expressTimetableTableView, cityTimetableTableView].forEach {
            $0.tapIncorrectButtonPublisher.sink { [weak self] in
                self?.tapIncorrentInfoButton()
            }.store(in: &subscriptions)
        }
        
        pageTableViews.forEach { tableView in
            tableView.publisher(for: \.contentOffset).sink { [weak self, weak tableView] _ in
                guard let self, let tableView, tableView === self.pageTableViews[self.selectedIndex] else { return }
                self.updateHeaderPosition()
            }.store(in: &subscriptions)
            
            tableView.publisher(for: \.contentSize).removeDuplicates().sink { [weak self, weak tableView] _ in
                guard let self, let tableView else { return }
                self.updateBottomInset(of: tableView)
            }.store(in: &subscriptions)
        }
    }
    
    private func bindRouteView(_ routeView: BusTimetableRouteView, busType: BusType) {
        // CurrentValueSubject 초기값 방출은 건너뛰고, setBusType/칩 선택 시점에만 조회한다.
        routeView.busFilterIdxPublisher.dropFirst().sink { [weak self] firstIdx, secondIdx in
            self?.inputSubject.send(.getBusTimetable(busType, firstIdx, secondIdx))
        }.store(in: &subscriptions)
        
        routeView.firstFilterPublisher.sink { [weak self] route in
            switch busType {
            case .shuttleBus:
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.shuttleBusRoute, .click, route))
            case .expressBus:
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.dsBusDirection, .click, route))
            default:
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.cityBusDirection, .click, route))
            }
        }.store(in: &subscriptions)
    }
    
    private func tapIncorrentInfoButton() {
        let logValue: String
        switch currentBusType() {
        case .shuttleBus:
            logValue = "셔틀버스 시간표"
        case .expressBus:
            logValue = "대성버스 시간표"
        default:
            logValue = "시내버스 시간표"
        }
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.errorFeedbackButton, .click, logValue))
        if let url = URL(string: "https://docs.google.com/forms/d/1GR4t8IfTOrYY4jxq5YAS7YiCS8QIFtHaWu_kE-SdDKY"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func tapDeleteNoticeInfoButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.busAnnouncementClose, .click, "\(currentBusType().koreanDescription) 시간표"))
        UserDefaults.standard.set(busNoticeWrappedView.tag, forKey: "busNoticeId")
        updateLayoutsByNotice(isDeleted: true)
    }
    
    @objc private func tapNoticeInfoButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.busAnnouncement, .click, "\(currentBusType().koreanDescription) 시간표"))
        let repository = DefaultNoticeListRepository(service: DefaultNoticeService())
        let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: DefaultFetchNoticeDataUseCase(noticeListRepository: repository), fetchHotNoticeArticlesUseCase: DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository), downloadNoticeAttachmentUseCase: DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), noticeId: busNoticeWrappedView.tag, boardId: -1)
        let viewController = NoticeDataViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func currentBusType() -> BusType {
        return busTypes[selectedIndex]
    }
    
    private func routeView(for busType: BusType) -> BusTimetableRouteView {
        switch busType {
        case .shuttleBus: return shuttleRouteView
        case .expressBus: return expressRouteView
        default: return cityRouteView
        }
    }
    
    private func updateBusRoute(busType: BusType, firstBusRoute: [String], secondBusRoute: [String]?) {
        routeView(for: busType).setBusType(busType: busType, firstRouteList: firstBusRoute, secondRouteList: secondBusRoute)
    }
    
    private func updateBusTimetable(busType: BusType, timetableInfo: BusTimetableInfo) {
        switch busType {
        case .expressBus:
            expressTimetableTableView.updateBusInfo(busInfo: timetableInfo)
        case .cityBus:
            cityTimetableTableView.updateBusInfo(busInfo: timetableInfo)
        default:
            break
        }
    }
    
    private func updateBusStopLabel(busType: BusType, busStop: String) {
        busStopTexts[busType] = busStop
        updateHeaderContents()
    }
    
    private func updateShuttleBusRoutes(busRoutes: ShuttleRouteDto) {
        shuttleTimetableTableView.updateShuttleBusInfo(busInfo: busRoutes)
    }
    
    private func updateEmergencyNotice(notice: BusNoticeDto) {
        busNoticeLabel.text = notice.title
        busNoticeWrappedView.tag = notice.id
        let noticeId = UserDefaults.standard.object(forKey: "busNoticeId") as? Int
        updateLayoutsByNotice(isDeleted: noticeId == notice.id || noticeId != nil)
    }
}

// MARK: - Paging
extension BusTimetableViewController {
    private func tapTab(index: Int) {
        guard index != selectedIndex else { return }
        syncInactivePageOffsets()
        selectPage(index: index)
        pagingScrollView.setContentOffset(CGPoint(x: pagingScrollView.bounds.width * CGFloat(index), y: 0), animated: true)
    }
    
    /// 탭 탭·페이지 스와이프 모두 이 경로로 선택 상태를 갱신한다(로그 1회).
    private func selectPage(index: Int) {
        guard index != selectedIndex, busTypes.indices.contains(index) else { return }
        selectedIndex = index
        busTypeTabBarView.update(selectedIndex: index)
        updateHeaderContents()
        updateHeaderPosition()
        let logValue: String
        switch currentBusType() {
        case .shuttleBus: logValue = "셔틀"
        case .expressBus: logValue = "대성"
        default: logValue = "시내"
        }
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.timetableBusTypeTab, .click, logValue))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === pagingScrollView, scrollView.bounds.width > 0 else { return }
        busTypeTabBarView.updateIndicator(progress: scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === pagingScrollView else { return }
        syncInactivePageOffsets()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate, scrollView === pagingScrollView, scrollView.bounds.width > 0 else { return }
        selectPage(index: Int(round(scrollView.contentOffset.x / scrollView.bounds.width)))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === pagingScrollView, scrollView.bounds.width > 0 else { return }
        selectPage(index: Int(round(scrollView.contentOffset.x / scrollView.bounds.width)))
    }
}

// MARK: - Collapsing Header
extension BusTimetableViewController {
    private var pageTopInset: CGFloat { headerHeight + tabBarHeight }
    
    /// 현재 페이지 스크롤 양만큼 헤더를 올린다. headerHeight 이상 스크롤되면 탭바만 상단에 고정된다.
    private var currentCollapse: CGFloat {
        let tableView = pageTableViews[selectedIndex]
        return min(max(tableView.contentOffset.y + pageTopInset, 0), headerHeight)
    }
    
    private func updateHeaderPosition() {
        headerTopConstraint?.update(offset: -currentCollapse)
    }
    
    /// 페이지 전환 전, 다른 페이지의 스크롤 위치를 헤더 접힘 상태에 맞춘다.
    private func syncInactivePageOffsets() {
        let collapse = currentCollapse
        let collapsedOffsetY = headerHeight - pageTopInset
        pageTableViews.enumerated().forEach { index, tableView in
            guard index != selectedIndex else { return }
            tableView.layoutIfNeeded()
            if collapse < headerHeight {
                tableView.contentOffset.y = collapse - pageTopInset
            } else if tableView.contentOffset.y < collapsedOffsetY {
                tableView.contentOffset.y = collapsedOffsetY
            }
        }
    }
    
    /// 콘텐츠가 짧아도 헤더가 완전히 접힐 만큼 스크롤 가능하게 하단 inset을 보정한다. 최소값은 홈 인디케이터 영역.
    private func updateBottomInset(of tableView: UITableView) {
        let visibleHeight = tableView.bounds.height - tabBarHeight
        let bottomInset = max(view.safeAreaInsets.bottom, visibleHeight - tableView.contentSize.height)
        guard tableView.contentInset.bottom != bottomInset else { return }
        tableView.contentInset.bottom = bottomInset
    }
    
    private func updatePageInsets() {
        pageTableViews.forEach { tableView in
            let wasAtTop = tableView.contentOffset.y <= -tableView.contentInset.top
            tableView.contentInset.top = pageTopInset
            tableView.verticalScrollIndicatorInsets.top = pageTopInset
            updateBottomInset(of: tableView)
            if wasAtTop {
                tableView.contentOffset.y = -pageTopInset
            }
        }
        updateHeaderPosition()
    }
    
    private func updateHeaderContents() {
        let busType = currentBusType()
        typeOftimetableLabel.text = "\(busType.koreanDescription) 시간표"
        let busStop = busType == .shuttleBus ? nil : busStopTexts[busType]
        busStopLabel.text = busStop
        busStopLabel.isHidden = busStop == nil
        busStopImageView.isHidden = busStop == nil
    }
    
    private func updateLayoutsByNotice(isDeleted: Bool) {
        busNoticeWrappedView.isHidden = isDeleted
        headerHeight = isDeleted ? 48 : 120
        timetableHeaderView.snp.updateConstraints {
            $0.height.equalTo(headerHeight)
        }
        updatePageInsets()
    }
}

extension BusTimetableViewController {
    private func setUpLayouts() {
        view.addSubview(contentContainerView)
        [pagingScrollView, headerContainerView].forEach {
            contentContainerView.addSubview($0)
        }
        pagingScrollView.addSubview(pageStackView)
        pageTableViews.forEach {
            pageStackView.addArrangedSubview($0)
        }
        [timetableHeaderView, busTypeTabBarView].forEach {
            headerContainerView.addSubview($0)
        }
        [typeOftimetableLabel, busNoticeWrappedView, busStopImageView, busStopLabel].forEach {
            timetableHeaderView.addSubview($0)
        }
        [busNoticeLabel, deleteNoticeButton].forEach {
            busNoticeWrappedView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pagingScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        pageStackView.snp.makeConstraints {
            $0.edges.equalTo(pagingScrollView.contentLayoutGuide)
            $0.height.equalTo(pagingScrollView.frameLayoutGuide)
            $0.width.equalTo(pagingScrollView.frameLayoutGuide).multipliedBy(busTypes.count)
        }
        headerContainerView.snp.makeConstraints {
            headerTopConstraint = $0.top.equalToSuperview().constraint
            $0.leading.trailing.equalToSuperview()
        }
        timetableHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(headerHeight)
        }
        busTypeTabBarView.snp.makeConstraints {
            $0.top.equalTo(timetableHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(tabBarHeight)
        }
        typeOftimetableLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(32)
        }
        busNoticeWrappedView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(typeOftimetableLabel.snp.bottom).offset(16)
            $0.height.equalTo(56)
        }
        busNoticeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(40)
        }
        deleteNoticeButton.snp.makeConstraints {
            $0.centerY.equalTo(busNoticeLabel)
            $0.leading.equalTo(busNoticeLabel.snp.trailing)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        busStopLabel.snp.makeConstraints {
            $0.trailing.equalTo(busStopImageView.snp.leading).offset(-4)
            $0.centerY.equalTo(busStopImageView)
        }
        busStopImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(typeOftimetableLabel)
            $0.width.height.equalTo(18)
        }
    }
    
    private func configurePageTableViews() {
        let routeViews: [(BusTimetableRouteView, BusType)] = [(shuttleRouteView, .shuttleBus), (expressRouteView, .expressBus), (cityRouteView, .cityBus)]
        zip(pageTableViews, routeViews).forEach { tableView, routeInfo in
            let (routeView, busType) = routeInfo
            routeView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: BusTimetableRouteView.height(for: busType))
            tableView.tableHeaderView = routeView
            tableView.sectionHeaderTopPadding = 0
            tableView.contentInset.top = pageTopInset
            tableView.verticalScrollIndicatorInsets.top = pageTopInset
            tableView.contentOffset.y = -pageTopInset
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        configurePageTableViews()
        view.backgroundColor = .systemBackground
    }
}
