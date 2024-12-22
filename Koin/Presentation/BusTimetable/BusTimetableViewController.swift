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

final class BusTimetableViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private var inputSubject: PassthroughSubject<BusTimetableViewModel.Input, Never> = .init()
    private let viewModel: BusTimetableViewModel
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let timetableHeaderView = UIView()
    
    private let typeOftimetableLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 20)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.text = "셔틀버스 시간표"
    }
    
    private let busNoticeWrappedView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.info100)
        $0.layer.cornerRadius = 8
        $0.isUserInteractionEnabled = true
    }
    
    private let busNoticeLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let deleteNoticeButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .delete), for: .normal)
    }
    
    private let busTypeSegmentControl = UISegmentedControl().then {
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.insertSegment(withTitle: "셔틀", at: 0, animated: true)
        $0.insertSegment(withTitle: "대성", at: 1, animated: true)
        $0.insertSegment(withTitle: "시내", at: 2, animated: true)
        $0.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500), NSAttributedString.Key.font: UIFont.appFont(.pretendardRegular, size: 16)], for: .normal)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary500), NSAttributedString.Key.font: UIFont.appFont(.pretendardBold, size: 16)], for: .selected)
        $0.layer.masksToBounds = false
    }
    
    private let shadowView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral400)
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.02, x: 0, y: 1, blur: 1, spread: 0)
    }
    
    private let selectedUnderlineView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
    }
    
    private let busTimetableRouteView = BusTimetableRouteView()
    
    private let expressOrCityTimetableTableView = ExpressOrCityTimetableTableView(frame: .zero, style: .grouped)
    
    private let shuttleTimetableTableView = ShuttleTimetableTableView(frame: .zero, style: .grouped)
    
    private let busStopImageView = UIImageView().then {
        $0.image = .appImage(asset: .busStop)
    }
    
    private let busStopLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 13)
        $0.textColor = .appColor(.primary500)
        $0.textAlignment = .right
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
        busTypeSegmentControl.selectedSegmentIndex = 0
        busTypeSegmentControl.addTarget(self, action: #selector(changeSegmentControl), for: .valueChanged)
        deleteNoticeButton.addTarget(self, action: #selector(tapDeleteNoticeInfoButton), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapNoticeInfoButton))
        busNoticeWrappedView.addGestureRecognizer(tapGesture)
        scrollView.delegate = self
        bind()
        inputSubject.send(.getBusRoute(.shuttleBus))
        inputSubject.send(.getEmergencyNotice)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
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
            case let .updateStopLabel(busStop):
                self?.updateBusStopLabel(busStop: busStop)
            }
        }.store(in: &subscriptions)
        
        busTimetableRouteView.busRouteContentHeightPublisher.sink { [weak self] height in
            DispatchQueue.main.async { [weak self] in
                self?.busTimetableRouteView.snp.updateConstraints {
                    $0.height.equalTo(height)
                }
            }
        }.store(in: &subscriptions)
        
        shuttleTimetableTableView.moveDetailTimetablePublisher.sink { [weak self] id, routeType, routeName in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.areaSpecificRoute, .click, "\(routeType.prefix(2))_\(routeName)"))
            let busRepository = DefaultBusRepository(service: DefaultBusService())
            let viewController = BusTimetableDataViewController(viewModel: BusTimetableDataViewModel(fetchShuttleTimetableUseCase: DefaultFetchShuttleBusTimetableUseCase(repository: busRepository), shuttleRouteId: id))
            viewController.title = "\(routeName) 시간표"
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        busTimetableRouteView.busFilterIdxPublisher.sink { [weak self] (firstIdx, secondIdx) in
            guard let self = self else { return }
            self.inputSubject.send(.getBusTimetable(currentBusType(), firstIdx, secondIdx))
        }.store(in: &subscriptions)
        
        busTimetableRouteView.firstFilterPublisher.sink { [weak self] route in
            switch self?.currentBusType() {
            case .shuttleBus:
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.shuttleBusRoute, .click, route))
            case .expressBus:
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.dsBusDirection, .click, route))
            default:
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.cityBusDirection, .click, route))
            }
        }.store(in: &subscriptions)
        
        busTimetableRouteView.secondFilterPublisher.sink { [weak self] busNumber in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.cityBusRoute, .click, busNumber))
        }.store(in: &subscriptions)
        
        expressOrCityTimetableTableView.heightPublisher.sink { [weak self] height in
            DispatchQueue.main.async { [weak self] in
                if self?.shuttleTimetableTableView.isHidden ?? false {
                    self?.contentView.snp.updateConstraints {
                        $0.height.equalTo(height + 300)
                    }
                }
            }
        }.store(in: &subscriptions)
    
        shuttleTimetableTableView.heightPublisher.sink { [weak self] height in
            DispatchQueue.main.async { [weak self] in
                if !(self?.shuttleTimetableTableView.isHidden ?? false) {
                    self?.contentView.snp.updateConstraints {
                        $0.height.equalTo(height + 300)
                    }
                }
            }
        }.store(in: &subscriptions)
        
        shuttleTimetableTableView.tapIncorrectButtonPublisher.sink { [weak self] in
            self?.tapIncorrentInfoButton()
        }.store(in: &subscriptions)
        
        expressOrCityTimetableTableView.tapIncorrectButtonPublisher.sink { [weak self] in
            self?.tapIncorrentInfoButton()
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
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.errorFeedbackButton, .click, logValue))
        if let url = URL(string: "https://docs.google.com/forms/d/1GR4t8IfTOrYY4jxq5YAS7YiCS8QIFtHaWu_kE-SdDKY"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func configureSwipeGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        shuttleTimetableTableView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeLeftGestureExpress = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGestureExpress.direction = .left
        expressOrCityTimetableTableView.addGestureRecognizer(swipeLeftGestureExpress)
        swipeLeftGesture.delegate = self
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        swipeRightGesture.delegate = self
        expressOrCityTimetableTableView.addGestureRecognizer(swipeRightGesture)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let currentSegmentIndex = busTypeSegmentControl.selectedSegmentIndex
        if gesture.direction == .left {
            if currentSegmentIndex < busTypeSegmentControl.numberOfSegments - 1 {
                busTypeSegmentControl.selectedSegmentIndex = currentSegmentIndex + 1
            }
        } else if gesture.direction == .right {
            if currentSegmentIndex > 0 {
                busTypeSegmentControl.selectedSegmentIndex = currentSegmentIndex - 1
            }
        }
        changeSegmentControl(sender: busTypeSegmentControl)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self.view)
        if timetableHeaderView.frame.contains(location) {
            return false
        }
        return true
    }
    
    @objc private func tapDeleteNoticeInfoButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busAnnouncementClose, .click, "버스 시간표"))
        UserDefaults.standard.set(busNoticeWrappedView.tag, forKey: "busNoticeId")
        updateLayoutsByNotice(isDeleted: true)
    }
    
    @objc private func tapNoticeInfoButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busAnnouncement, .click, "버스 시간표"))
        let repository = DefaultNoticeListRepository(service: DefaultNoticeService())
        let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: DefaultFetchNoticeDataUseCase(noticeListRepository: repository), fetchHotNoticeArticlesUseCase: DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository), downloadNoticeAttachmentUseCase: DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), noticeId: busNoticeWrappedView.tag)
        let viewController = NoticeDataViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func changeSegmentControl(sender: UISegmentedControl) {
        moveUnderLineView()
        inputSubject.send(.getBusRoute(currentBusType()))
        let logValue: String
        switch busTypeSegmentControl.selectedSegmentIndex {
        case 0:
            DispatchQueue.main.async { [weak self] in
                self?.shuttleTimetableTableView.isHidden = false
                self?.expressOrCityTimetableTableView.isHidden = true
            }
            logValue = "셔틀"
        case 1:
            DispatchQueue.main.async { [weak self] in
                self?.shuttleTimetableTableView.isHidden = true
                self?.expressOrCityTimetableTableView.isHidden = false
                self?.updateLayoutsByNotice(isDeleted: true)
            }
            logValue = "대성"
        default:
            DispatchQueue.main.async { [weak self] in
                self?.shuttleTimetableTableView.isHidden = true
                self?.expressOrCityTimetableTableView.isHidden = false
            }
            logValue = "시내"
        }
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.timetableBusTypeTab, .click, logValue))
    }
    
    private func currentBusType() -> BusType {
        let busType: BusType
        switch busTypeSegmentControl.selectedSegmentIndex {
        case 0:
            busType = .shuttleBus
        default:
            busType = busTypeSegmentControl.selectedSegmentIndex == 1 ? .expressBus : .cityBus
        }
        return busType
    }
    
    private func moveUnderLineView() {
        let newXPosition = (busTypeSegmentControl.frame.width / CGFloat(busTypeSegmentControl.numberOfSegments)) * CGFloat(busTypeSegmentControl.selectedSegmentIndex)
        selectedUnderlineView.snp.updateConstraints {
            $0.leading.equalTo(busTypeSegmentControl).offset(newXPosition)
        }
        UIView.animate (
            withDuration: 0.4,
            animations: { [weak self] in
                guard let self = self
                else { return }
                self.view.layoutIfNeeded()
            }
        )
    }
    
    private func updateBusRoute(busType: BusType, firstBusRoute: [String], secondBusRoute: [String]?) {
        busTimetableRouteView.setBusType(busType: busType, firstRouteList: firstBusRoute, secondRouteList: secondBusRoute)
        switch busType {
        case .shuttleBus:
            typeOftimetableLabel.text = "셔틀버스 시간표"
            inputSubject.send(.getBusTimetable(.shuttleBus, 0, nil))
        case .expressBus:
            typeOftimetableLabel.text = "대성고속 시간표"
            inputSubject.send(.getBusTimetable(.expressBus, 0, nil))
        default:
            typeOftimetableLabel.text = "시내버스 시간표"
            inputSubject.send(.getBusTimetable(.cityBus, 0, 0))
        }
    }
    
    private func updateBusTimetable(busType: BusType, timetableInfo: BusTimetableInfo) {
        busStopLabel.isHidden = false
        busStopImageView.isHidden = false
        expressOrCityTimetableTableView.updateBusInfo(busInfo: timetableInfo)
    }
    
    private func updateBusStopLabel(busStop: String) {
        busStopLabel.text = busStop
    }
    
    private func updateShuttleBusRoutes(busRoutes: ShuttleRouteDTO) {
        busStopLabel.isHidden = true
        busStopImageView.isHidden = true
        shuttleTimetableTableView.updateShuttleBusInfo(busInfo: busRoutes)
    }
    
    private func updateEmergencyNotice(notice: BusNoticeDTO) {
        updateLayoutsByNotice(isDeleted: false)
        busNoticeLabel.text = notice.title
        busNoticeWrappedView.tag = notice.id
        let noticeId = UserDefaults.standard.object(forKey: "busNoticeId") as? Int
        if noticeId == notice.id || noticeId != nil {
            updateLayoutsByNotice(isDeleted: true)
        }
    }
}

extension BusTimetableViewController {
    private func setUpLayouts() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [timetableHeaderView, shadowView, selectedUnderlineView, busTypeSegmentControl, busTimetableRouteView, expressOrCityTimetableTableView, shuttleTimetableTableView].forEach {
            contentView.addSubview($0)
        }
        [typeOftimetableLabel, busNoticeWrappedView, busStopImageView, busStopLabel].forEach {
            timetableHeaderView.addSubview($0)
        }
        [busNoticeLabel, deleteNoticeButton].forEach {
            busNoticeWrappedView.addSubview($0)
        }
    }
    
    private func updateLayoutsByNotice(isDeleted: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isDeleted {
                self?.busNoticeWrappedView.isHidden = true
                self?.timetableHeaderView.snp.updateConstraints {
                    $0.height.equalTo(48)
                }
            }
            else {
                self?.busNoticeWrappedView.isHidden = false
                self?.timetableHeaderView.snp.updateConstraints {
                    $0.height.equalTo(120)
                }
            }
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1000)
        }
        timetableHeaderView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(139)
        }
        typeOftimetableLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalTo(24)
            $0.height.equalTo(32)
        }
        busNoticeWrappedView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(typeOftimetableLabel.snp.bottom).offset(8)
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
        busTypeSegmentControl.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(timetableHeaderView.snp.bottom)
            $0.height.equalTo(50)
        }
        shadowView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(busTypeSegmentControl.snp.bottom)
            $0.height.equalTo(1)
        }
        selectedUnderlineView.snp.makeConstraints {
            $0.leading.equalTo(busTypeSegmentControl.snp.leading)
            $0.height.equalTo(2)
            $0.top.equalTo(busTypeSegmentControl.snp.bottom)
            $0.width.equalTo(busTypeSegmentControl.snp.width).dividedBy(busTypeSegmentControl.numberOfSegments)
        }
        busTimetableRouteView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(selectedUnderlineView.snp.bottom)
            $0.height.equalTo(62)
        }
        expressOrCityTimetableTableView.snp.makeConstraints {
            $0.top.equalTo(busTimetableRouteView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        shuttleTimetableTableView.snp.makeConstraints {
            $0.top.equalTo(busTimetableRouteView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        busStopLabel.snp.makeConstraints {
            $0.trailing.equalTo(busStopImageView.snp.leading).offset(-4)
            $0.centerY.equalTo(busStopImageView)
        }
        busStopImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(typeOftimetableLabel)
            $0.height.equalTo(18)
            $0.width.equalTo(15)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .systemBackground
        configureSwipeGestures()
    }
}
