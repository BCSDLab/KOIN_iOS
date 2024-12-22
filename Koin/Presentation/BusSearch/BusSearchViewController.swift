//
//  BusSearchViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import DropDown
import SnapKit
import UIKit

final class BusSearchViewController: UIViewController {
    
    private let viewModel: BusSearchViewModel
    private let inputSubject: PassthroughSubject<BusSearchViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let searchMainDescriptionLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.text = "목적지까지 가장 빠른 교통편을 알려드릴게요."
    }
    
    private let searchSubDescriptionLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral600)
        $0.text = "학기 중 시간표와 다를 수 있습니다."
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
        $0.numberOfLines = 0
    }
    
    private let deleteNoticeButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .delete), for: .normal)
    }
    
    private let departGuideLabel = UILabel().then {
        $0.text = "출발"
    }
    
    private let arriveGuideLabel = UILabel().then {
        $0.text = "도착"
    }
    
    private let departAreaSelectedButton = UIButton()
    
    private let arrivedAreaSelectedButton = UIButton()
    
    private let swapAreaButton = UIButton().then {
        $0.setImage(.appImage(asset: .swap), for: .normal)
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
    }
    
    private let busInfoSearchButton = UIButton().then {
        $0.setAttributedTitle(NSAttributedString(string: "조회하기", attributes: [.font: UIFont.appFont(.pretendardMedium, size: 15)]), for: .normal)
        $0.backgroundColor = .appColor(.neutral300)
        $0.setTitleColor(.appColor(.neutral600), for: .normal)
        $0.layer.cornerRadius = 4
        $0.isEnabled = false
    }
    
    private let busAreaViewController = BusAreaSelectedViewController()
    
    // MARK: - Initialization
    
    init(viewModel: BusSearchViewModel) {
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
        busInfoSearchButton.addTarget(self, action: #selector(tapSearchButton), for: .touchUpInside)
        swapAreaButton.addTarget(self, action: #selector(swapDepartureAndArrival), for: .touchUpInside)
        deleteNoticeButton.addTarget(self, action: #selector(tapDeleteNoticeInfoButton), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapNoticeInfoButton))
        busNoticeWrappedView.addGestureRecognizer(tapGesture)
        bind()
        inputSubject.send(.fetchBusNotice)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didDismissDetailNotification(_:)),
            name: NSNotification.Name("DismissBusAreaSelectedView"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("DismissBusAreaSelectedView"), object: nil)
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateBusArea(buttonState, busPlace):
                self?.updateSelectedBusArea(buttonState: buttonState, busPlace: busPlace)
            case let .updateEmergencyNotice(notice):
                self?.updateEmergencyNotice(notice: notice)
            }
        }.store(in: &subscriptions)
        
        busAreaViewController.switchBusAreaPublisher.sink { [weak self] logValue, buttonState in
            if buttonState == .departure {
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.switchToDeparture, .click, logValue))
            }
            else {
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.switchToArrival, .click, logValue))
            }
        }.store(in: &subscriptions)
        
        busAreaViewController.departureBusAreaPublisher.sink { [weak self] departureArea in
            guard let self = self else { return }
            changeBusAreaButton(sender: departAreaSelectedButton, title: departureArea)
            if departAreaSelectedButton.tag != 0 && arrivedAreaSelectedButton.tag != 0 {
                manageSearchButton(isActivated: true)
            }
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.departureLocation, .click, departureArea.koreanDescription))
        }.store(in: &subscriptions)
        
        busAreaViewController.arrivalBusAreaPublisher.sink { [weak self] arrivedArea in
            guard let self = self else { return }
            changeBusAreaButton(sender: arrivedAreaSelectedButton, title: arrivedArea)
            if departAreaSelectedButton.tag != 0 && arrivedAreaSelectedButton.tag != 0 {
                manageSearchButton(isActivated: true)
            }
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.arrivalLocation, .click, arrivedArea.koreanDescription))
        }.store(in: &subscriptions)
        
        busAreaViewController.confirmPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.departureArrivalConfirm, .click, "확인하기"))
        }.store(in: &subscriptions)
    }
}

extension BusSearchViewController {
    @objc func didDismissDetailNotification(_ notification: Notification) {
        let departure = departAreaSelectedButton.tag != 0 ? BusPlace.allCases[departAreaSelectedButton.tag - 1] : nil
        let arrival = arrivedAreaSelectedButton.tag != 0 ? BusPlace.allCases[arrivedAreaSelectedButton.tag - 1] : nil
        
        busAreaViewController.dismissWithoutConfirmPublisher.send(((departure, arrival), notification.object))
    }

    @objc private func tapSearchButton(sender: UIButton) {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.departureArrivalConfirm, .click, "조회하기"))
        let repository = DefaultBusRepository(service: DefaultBusService())
        let departure = BusPlace.allCases[departAreaSelectedButton.tag - 1]
        let arrival = BusPlace.allCases[arrivedAreaSelectedButton.tag - 1]
        let viewModel = BusSearchResultViewModel(fetchDatePickerDataUseCase: DefaultFetchKoinPickerDataUseCase(), busPlaces: (departure, arrival), fetchSearchedResultUseCase: DefaultSearchBusInfoUseCase(busRepository: repository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
        let busSearchResultViewController = BusSearchResultViewController(viewModel: viewModel)
        busSearchResultViewController.title = "\(departure.koreanDescription) → \(arrival.koreanDescription)"
        navigationController?.pushViewController(busSearchResultViewController, animated: true)
    }
    
    @objc private func tapNoticeInfoButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busAnnouncement, .click, "교통편 조회하기"))
        let repository = DefaultNoticeListRepository(service: DefaultNoticeService())
        let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: DefaultFetchNoticeDataUseCase(noticeListRepository: repository), fetchHotNoticeArticlesUseCase: DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository), downloadNoticeAttachmentUseCase: DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), noticeId: busNoticeWrappedView.tag)
        let viewController = NoticeDataViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func tapBusAreaSelectedButtons(sender: UIButton) {
        let buttonState: BusAreaButtonState = sender == departAreaSelectedButton ? .departureSelect : .arrivalSelect
        if sender == departAreaSelectedButton {
            inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.departureBox, .click, "출발지 선택"))
        }
        else {
            inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.arrivalBox, .click, "도착지 선택"))
        }
        inputSubject.send(.selectBusArea(sender.tag, buttonState))
    }
    
    @objc private func tapDeleteNoticeInfoButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busAnnouncementClose, .click, "교통편 조회하기"))
        UserDefaults.standard.set(busNoticeWrappedView.tag, forKey: "busNoticeId")
        updateLayoutsByNotice(isDeleted: true)
    }
    
    @objc private func swapDepartureAndArrival(sender: UIButton) {
        guard departAreaSelectedButton.tag != 0 && arrivedAreaSelectedButton.tag != 0 else { return }
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.swapDestionation, .click, "스왑 버튼"))
        let departure = BusPlace.allCases[departAreaSelectedButton.tag - 1]
        let arrival = BusPlace.allCases[arrivedAreaSelectedButton.tag - 1]
        changeBusAreaButton(sender: departAreaSelectedButton, title: arrival)
        changeBusAreaButton(sender: arrivedAreaSelectedButton, title: departure)
        busAreaViewController.swap(departure: departure, arrival: arrival)
    }
    
    private func updateSelectedBusArea(buttonState: BusAreaButtonState, busPlace: BusPlace?) {
        var busAreaList: [(BusPlace, Bool)] = [(.koreatech, false), (.station, false), (.terminal, false)]
        for (index, value) in busAreaList.enumerated() {
            if value.0 == busPlace  {
                busAreaList[index].1 = true
            }
            else if busPlace == nil {
                busAreaList[0].1 = true
            }
        }

        busAreaViewController.configure(busAreaLists: busAreaList, buttonState: buttonState)
        let bottomSheet = BottomSheetViewController(contentViewController: busAreaViewController, defaultHeight: 361, cornerRadius: 32, isPannedable: false)
        bottomSheet.modalPresentationStyle = .overFullScreen
        bottomSheet.modalTransitionStyle = .crossDissolve
        present(bottomSheet, animated: true)
    }
    
    private func changeBusAreaButton(sender: UIButton, title: BusPlace) {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(title.koreanDescription, attributes: AttributeContainer([.font: UIFont.appFont(.pretendardBold, size: 18), .foregroundColor: UIColor.appColor(.neutral800)]))
        configuration.contentInsets = .init(top: 12, leading: 30, bottom: 12, trailing: 30)
        sender.configuration = configuration
        sender.backgroundColor = .clear
        sender.tag = (BusPlace.allCases.firstIndex(of: title) ?? 0) + 1
    }
    
    private func manageSearchButton(isActivated: Bool) {
        if !isActivated {
            busInfoSearchButton.backgroundColor = .appColor(.neutral300)
            busInfoSearchButton.setTitleColor(.appColor(.neutral600), for: .normal)
            busInfoSearchButton.isEnabled = false
        }
        else {
            busInfoSearchButton.isEnabled = true
            busInfoSearchButton.backgroundColor = .appColor(.primary500)
            busInfoSearchButton.setTitleColor(.appColor(.neutral0), for: .normal)
        }
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


extension BusSearchViewController {
    
    private func setUpLabels() {
        [departGuideLabel, arriveGuideLabel].forEach {
            $0.font = .appFont(.pretendardMedium, size: 16)
            $0.textColor = .appColor(.primary500)
            $0.textAlignment = .center
        }
    }

    private func setUpButtons() {
        let buttonNames = ["출발지 선택", "도착지 선택"]
        let buttons = [departAreaSelectedButton, arrivedAreaSelectedButton]
        for (index, value) in buttons.enumerated() {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(buttonNames[index], attributes: AttributeContainer([.font: UIFont.appFont(.pretendardRegular, size: 14), .foregroundColor: UIColor.appColor(.gray)]))
            configuration.contentInsets = .init(top: 12, leading: 30, bottom: 12, trailing: 30)
            value.configuration = configuration
            value.backgroundColor = .appColor(.neutral100)
            value.addTarget(self, action: #selector(tapBusAreaSelectedButtons), for: .touchUpInside)
        }
    }
    
    private func setUpLayOuts() {
        [searchMainDescriptionLabel, searchSubDescriptionLabel, departGuideLabel, arriveGuideLabel, departAreaSelectedButton, swapAreaButton, arrivedAreaSelectedButton, busInfoSearchButton, busNoticeWrappedView].forEach {
            view.addSubview($0)
        }
        
        [busNoticeLabel, deleteNoticeButton].forEach {
            busNoticeWrappedView.addSubview($0)
        }
    }
    
    private func updateLayoutsByNotice(isDeleted: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if isDeleted {
                self.busNoticeWrappedView.isHidden = true
                self.searchMainDescriptionLabel.snp.remakeConstraints {
                    $0.leading.equalToSuperview().offset(24)
                    $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
                }
            }
            else {
                self.busNoticeWrappedView.isHidden = false
                self.searchMainDescriptionLabel.snp.updateConstraints {
                    $0.top.equalTo(self.busNoticeWrappedView.snp.bottom).offset(18)
                }
            }
        }
    }
    
    private func setUpConstraints() {
        searchMainDescriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(busNoticeWrappedView.snp.bottom).offset(18)
        }
        searchSubDescriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(searchMainDescriptionLabel)
            $0.top.equalTo(searchMainDescriptionLabel.snp.bottom).offset(4)
        }
        departGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(127)
            $0.top.equalTo(searchSubDescriptionLabel.snp.bottom).offset(46)
        }
        arriveGuideLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.width.equalTo(127)
            $0.top.equalTo(departGuideLabel)
        }
        departAreaSelectedButton.snp.makeConstraints {
            $0.centerX.equalTo(departGuideLabel)
            $0.top.equalTo(departGuideLabel.snp.bottom).offset(8)
            $0.width.equalTo(143)
            $0.height.equalTo(46)
        }
        arrivedAreaSelectedButton.snp.makeConstraints {
            $0.centerX.equalTo(arriveGuideLabel)
            $0.top.equalTo(departAreaSelectedButton)
            $0.width.equalTo(143)
            $0.height.equalTo(46)
        }
        swapAreaButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(arrivedAreaSelectedButton)
        }
        busInfoSearchButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(59)
            $0.height.equalTo(48)
        }
        busNoticeWrappedView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        busNoticeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(deleteNoticeButton.snp.leading).inset(3)
        }
        deleteNoticeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
    }
    
    private func configureView() {
        setUpLabels()
        setUpButtons()
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
