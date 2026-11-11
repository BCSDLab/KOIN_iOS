//
//  BusTimetableDataViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/5/24.
//

import Combine
import UIKit
import SnapKit

final class BusTimetableDataViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Page
    private enum Page {
        /// 단일열(시간 | 승하차장명)
        case single(nodeInfo: [NodeInfo], arrivalTime: [String?], timeHeaderText: String)
        /// 회차 그리드(승하차장명 고정 + 회차 가로 스크롤)
        case grid(nodeInfo: [NodeInfo], routeInfo: [RouteInfo])
    }

    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private var pageSubscriptions: Set<AnyCancellable> = []
    private var inputSubject: PassthroughSubject<BusTimetableDataViewModel.Input, Never> = .init()
    private let viewModel: BusTimetableDataViewModel
    private var selectedIndex = 0
    private var lastPageWidth: CGFloat = 0
    private var tabBarHeightConstraint: Constraint?

    // MARK: - UI Components
    private let shuttleRouteTypeLabel = BusRouteTagLabel()

    private let busTimetablePlaceLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 20)
        $0.textColor = .appColor(.neutral800)
        $0.textAlignment = .left
    }

    private let subBusTimetablePlaceLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.textAlignment = .left
        $0.isHidden = true
    }

    private lazy var titleStackView = UIStackView(arrangedSubviews: [shuttleRouteTypeLabel, busTimetablePlaceLabel, subBusTimetablePlaceLabel]).then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
    }

    private let titleBorderView = UIView().then {
        $0.backgroundColor = .appColor(.neutral400)
        $0.isHidden = true
    }

    private let tabBarContainerView = UIView()

    private var tabBarView: BusTimetableTabBarView?
    /// 주중 노선의 등교/하교 탭 화면인지. 탭 문자열(서버 값, 다국어 예정)이 아니라 페이지 구성으로 판단한다.
    private var isCommuteTabs = false

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

    // MARK: - Initialization
    init(viewModel: BusTimetableDataViewModel) {
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
        bind()
        inputSubject.send(.getBusTimetable)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 페이지 폭이 바뀐 경우에만 보정한다. 탭 전환 애니메이션 중에 덮어쓰면 목표 페이지를 지나친다.
        let pageWidth = pagingScrollView.bounds.width
        guard pageWidth > 0, pageWidth != lastPageWidth else { return }
        lastPageWidth = pageWidth
        pagingScrollView.contentOffset.x = pageWidth * CGFloat(selectedIndex)
        tabBarView?.updateIndicator(progress: CGFloat(selectedIndex))
    }

    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateBusRoute(timetable):
                self?.updateShuttleBusTimetable(timetable: timetable)
            }
        }.store(in: &subscriptions)
    }
}

extension BusTimetableDataViewController {
    /// 명세 value 형식 {노선 구분}_{세부 노선}
    private var routeLogValue: String {
        "\(shuttleRouteTypeLabel.text ?? "")_\(busTimetablePlaceLabel.text ?? "")"
    }

    private func tapIncorrectInfoButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Bus.busTimetableBusFeedbackEntryClick, routeLogValue))
        if let url = URL(string: "https://docs.google.com/forms/d/1GR4t8IfTOrYY4jxq5YAS7YiCS8QIFtHaWu_kE-SdDKY"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func updateShuttleBusTimetable(timetable: ShuttleBusTimetable) {
        shuttleRouteTypeLabel.configure(shuttleRouteType: timetable.routeType)
        busTimetablePlaceLabel.text = timetable.routeName
        subBusTimetablePlaceLabel.text = timetable.subName
        subBusTimetablePlaceLabel.isHidden = timetable.subName?.isEmpty ?? true
        let (titles, pages) = makePages(timetable: timetable)
        isCommuteTabs = timetable.routeType == .weekday && timetable.routeInfo.count >= 2
        configureTabBar(titles: titles)
        configurePages(pages)
    }

    /// 응답 데이터로 탭 라벨과 페이지를 만든다.
    /// - 주중 + routeInfo 2개 이상: 단일열 페이지, 탭 = routeInfo 이름(등교/하교)
    /// - 주중 + routeInfo 1개: 단일열 1페이지, 탭 없음, 시간 컬럼 라벨 = routeInfo 이름
    /// - 그 외: 모든 routeInfo의 detail이 있고 종류가 2개 이상이면 detail별 그리드 페이지(탭 = detail), 아니면 그리드 1페이지
    private func makePages(timetable: ShuttleBusTimetable) -> (titles: [String], pages: [Page]) {
        let routeInfo = timetable.routeInfo
        if timetable.routeType == .weekday, !routeInfo.isEmpty {
            if routeInfo.count == 1, let route = routeInfo.first {
                return ([], [.single(nodeInfo: timetable.nodeInfo, arrivalTime: route.arrivalTime, timeHeaderText: route.name)])
            }
            let pages: [Page] = routeInfo.enumerated().map { index, route in
                // 하교 arrivalTime은 DTO 변환 시 이미 역순(ShuttleBusTimetableDto) → 정류장만 뒤집는다(기존 동작).
                let nodeInfo = index == 0 ? timetable.nodeInfo : timetable.nodeInfo.reversed()
                return .single(nodeInfo: nodeInfo, arrivalTime: route.arrivalTime, timeHeaderText: "시간")
            }
            return (routeInfo.map { $0.name }, pages)
        }

        let details = routeInfo.compactMap { $0.detail }.filter { !$0.isEmpty }
        var groupTitles: [String] = []
        details.forEach { if !groupTitles.contains($0) { groupTitles.append($0) } }
        if details.count == routeInfo.count, groupTitles.count >= 2 {
            let pages: [Page] = groupTitles.map { title in
                let routes = routeInfo
                    .filter { $0.detail == title }
                    .map { RouteInfo(name: $0.name, detail: nil, arrivalTime: $0.arrivalTime) }
                return .grid(nodeInfo: timetable.nodeInfo, routeInfo: routes)
            }
            return (groupTitles, pages)
        }
        return ([], [.grid(nodeInfo: timetable.nodeInfo, routeInfo: routeInfo)])
    }

    private func configureTabBar(titles: [String]) {
        tabBarView?.removeFromSuperview()
        tabBarView = nil
        let hasTabs = titles.count > 1
        titleBorderView.isHidden = hasTabs
        tabBarHeightConstraint?.update(offset: hasTabs ? 50 : 0)
        guard hasTabs else { return }
        let tabBarView = BusTimetableTabBarView(titles: titles)
        tabBarContainerView.addSubview(tabBarView)
        tabBarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.tabBarView = tabBarView
    }

    private func configurePages(_ pages: [Page]) {
        pageSubscriptions.removeAll()
        if let tabBarView {
            tabBarView.selectTabPublisher.sink { [weak self] index in
                self?.tapTab(index: index)
            }.store(in: &pageSubscriptions)
        }
        pageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pages.forEach { page in
            let pageView: UIView
            switch page {
            case let .single(nodeInfo, arrivalTime, timeHeaderText):
                let tableView = OneBusTimetableTableView(frame: .zero, style: .grouped)
                tableView.configure(nodeInfo: nodeInfo, routeInfo: arrivalTime, timeHeaderText: timeHeaderText)
                tableView.tapIncorrectButtonPublisher.sink { [weak self] in
                    self?.tapIncorrectInfoButton()
                }.store(in: &pageSubscriptions)
                pageView = tableView
            case let .grid(nodeInfo, routeInfo):
                let gridView = BusTimetableGridPageView()
                let isExpandedHeader = pages.count > 1 || routeInfo.contains { !($0.detail ?? "").isEmpty }
                gridView.configure(
                    nodeInfo: nodeInfo,
                    routeInfo: routeInfo,
                    headerRowHeight: isExpandedHeader ? BusTimetableGridPageView.expandedHeaderRowHeight : BusTimetableGridPageView.compactHeaderRowHeight
                )
                gridView.tapIncorrectButtonPublisher.sink { [weak self] in
                    self?.tapIncorrectInfoButton()
                }.store(in: &pageSubscriptions)
                pageView = gridView
            }
            pageStackView.addArrangedSubview(pageView)
        }
        pageStackView.snp.remakeConstraints {
            $0.edges.equalTo(pagingScrollView.contentLayoutGuide)
            $0.height.equalTo(pagingScrollView.frameLayoutGuide)
            $0.width.equalTo(pagingScrollView.frameLayoutGuide).multipliedBy(max(pages.count, 1))
        }
        pagingScrollView.isScrollEnabled = pages.count > 1
        selectedIndex = 0
        tabBarView?.update(selectedIndex: 0)
        tabBarView?.updateIndicator(progress: 0)
        pagingScrollView.contentOffset.x = 0
    }
}

// MARK: - Paging
extension BusTimetableDataViewController {
    private func tapTab(index: Int) {
        guard index != selectedIndex else { return }
        // 명세 4-7·4-8: 주중 노선 탭은 첫 번째가 등교, 나머지가 하교다 (makePages의 정류장 순서 기준과 같음).
        if isCommuteTabs {
            let label: EventLabelType = index == 0
                ? EventParameter.EventLabel.Bus.busTimetableDetailFilterToSchoolClick
                : EventParameter.EventLabel.Bus.busTimetableDetailFilterToHomeClick
            inputSubject.send(.logEvent(label, routeLogValue))
        }
        selectPage(index: index)
        pagingScrollView.setContentOffset(CGPoint(x: pagingScrollView.bounds.width * CGFloat(index), y: 0), animated: true)
    }

    /// 탭 탭·페이지 스와이프 모두 이 경로로 선택 상태를 갱신한다.
    private func selectPage(index: Int) {
        guard index != selectedIndex, pageStackView.arrangedSubviews.indices.contains(index) else { return }
        selectedIndex = index
        tabBarView?.update(selectedIndex: index)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === pagingScrollView, scrollView.bounds.width > 0 else { return }
        tabBarView?.updateIndicator(progress: scrollView.contentOffset.x / scrollView.bounds.width)
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

extension BusTimetableDataViewController {
    private func setUpLayouts() {
        [titleStackView, tabBarContainerView, pagingScrollView, titleBorderView].forEach {
            view.addSubview($0)
        }
        pagingScrollView.addSubview(pageStackView)
    }

    private func setUpConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        shuttleRouteTypeLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        busTimetablePlaceLabel.snp.makeConstraints {
            $0.height.equalTo(32)
        }
        subBusTimetablePlaceLabel.snp.makeConstraints {
            $0.height.equalTo(19)
        }
        tabBarContainerView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            tabBarHeightConstraint = $0.height.equalTo(0).constraint
        }
        titleBorderView.snp.makeConstraints {
            $0.top.equalTo(tabBarContainerView)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        pagingScrollView.snp.makeConstraints {
            $0.top.equalTo(tabBarContainerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pageStackView.snp.makeConstraints {
            $0.edges.equalTo(pagingScrollView.contentLayoutGuide)
            $0.height.equalTo(pagingScrollView.frameLayoutGuide)
            $0.width.equalTo(pagingScrollView.frameLayoutGuide)
        }
    }

    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .systemBackground
        pagingScrollView.delegate = self
    }
}
