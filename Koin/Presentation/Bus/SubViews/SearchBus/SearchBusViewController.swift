//
//  SearchBusInfoViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/03/30.
//

import Combine
import DropDown
import SnapKit
import UIKit

final class SearchBusViewController: UIViewController {
    // MARK: - Properties
    private let inputSubject: PassthroughSubject<BusViewModel.Input, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: BusViewModel
    
    // MARK: - UI Components
    private let busPlaceDropDown = DropDown()
    private let selectedBusPlaceWrappedView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let dateChoiceSign: UILabel = {
        let label = UILabel()
        label.text = "날짜선택"
        label.textColor = .appColor(.neutral500)
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let timeChoiceSign: UILabel = {
        let label = UILabel()
        label.text = "시간선택"
        label.textColor = .appColor(.neutral500)
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    //출발지 선택 버튼 (e.g 한기대)
    private let selectedDepartureBtn = {
        let button = UIButton()
    
        button.semanticContentAttribute = .forceRightToLeft
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        return button
    }()
    
    //도착지 선택 버튼 (e.g 야우리)
    private let selectedArrivalBtn = {
        let button = UIButton()
        
        button.semanticContentAttribute = .forceRightToLeft
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        return button
    }()
    
    private let selectedDateBtn: UIButton = {
        let button = UIButton()
        button.tintColor = .appColor(.neutral800)
        return button
    }()
    
    private lazy var stackViewForPlace: UIStackView = {
        let stackView = UIStackView()
        let label1 = UILabel()
        let label2 = UILabel()
        label1.text = "에서  "
        label2.text = "갑니다"
        
        label1.textColor = .appColor(.neutral800)
        label1.textColor = .appColor(.neutral800)
        
        label1.font = UIFont.appFont(.pretendardRegular, size: 20)
        label2.font = UIFont.appFont(.pretendardRegular, size: 20)
        
        [selectedDepartureBtn, label1, selectedArrivalBtn, label2].forEach{
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        
        return stackView
    }()
    
    private let dateBtnWrappedView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let departedTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColor(.bus1)
        label.font = UIFont.appFont(.pretendardMedium, size: 15)
        return label
    }()
    
    private let departedDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColor(.bus1)
        label.font = UIFont.appFont(.pretendardMedium, size: 15)
        return label
    }()
    
    private let searchedDepartureBtn: UIButton = {
        var config = UIButton.Configuration.filled()
        
        config.title = "조회"
        config.baseForegroundColor = UIColor.white
        config.baseBackgroundColor = .appColor(.bus1)
        config.contentInsets = .init(top: 5, leading: 18, bottom: 5, trailing: 18)
        config.cornerStyle = .small
        let button = UIButton(configuration: config)
        
        return button
    }()
    
    private let departedTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "Ko")
        datePicker.datePickerMode = .time
        return datePicker
    }()
    
    private let departedDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko")
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private let timePickerWrappedView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let searchAreaWrappedView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    // MARK: - Initialization
    init(viewModel: BusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setUpViewLayers()
        setUpButtons()
        setUpLayout()
        bind()
        self.view.backgroundColor = UIColor.systemGray6
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeView()
    }
    
    private func bind() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        output.receive(on: DispatchQueue.main)
            .sink { [weak self] event in
            switch event {
            case .updateBusRoute(let departure, let arrival):
                self?.updateDepartureAndArrivalText(departure: departure, arrival: arrival)
            case .setBusSearchedResult(let searchedBusResult):
                self?.showResultAlert(searchedResult: searchedBusResult)
            default:
                print("")
            }
            
        }.store(in: &cancellables)
    }
}
extension SearchBusViewController {
    
    @objc private func showBusPlaceOptionsAlert(sender: UIButton) {
        var placeList: [String] = []
        for busPlace in BusPlace.allCases {
            placeList.append(busPlace.koreanDescription)
        }
        let chevronImageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium, scale: .medium)
        let chevronImageView = UIImage(systemName: SFSymbols.chevronUp.rawValue, withConfiguration: chevronImageConfig)
        sender.setImage(chevronImageView, for: .normal)
        busPlaceDropDown.dataSource = placeList
        busPlaceDropDown.anchorView = sender
        busPlaceDropDown.bottomOffset = CGPoint(x: 0, y: sender.bounds.height)
        busPlaceDropDown.selectionAction = { [weak self] (index, item) in
            guard let self = self else {return}
            
            if sender == self.selectedDepartureBtn {
                self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busSearchDeparture, EventParameter.EventCategory.click, item))
            }
            else if sender == self.selectedArrivalBtn {
                self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busSearchArrival, EventParameter.EventCategory.click, item))
            }
            let lastBtnTag = sender.tag
            
            self.getBusRoute(sender: sender, lastSelectedTag: lastBtnTag, nowSelectedTag: index)
            let chevronImageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium, scale: .medium)
            let chevronImageView = UIImage(systemName: SFSymbols.chevronDown.rawValue, withConfiguration: chevronImageConfig)
            sender.setImage(chevronImageView, for: .normal)
        }
        busPlaceDropDown.show()
    }
    
    @objc private func updateDate() {
        let departedDateForLabel = self.departedDatePicker.date.formatDateToYYYYMMDD(separator: "/")
        let departedDateForBtn = self.departedDatePicker.date.formatDateToMDE()
        
        self.departedDateLabel.text = departedDateForLabel
        updateDateBtn(date: departedDateForBtn)
    }
    
    @objc private func updateTime() {
        let departedTimeForLabel = self.departedTimePicker.date.formatDateToHHMM(isHH: false)
        self.departedTimeLabel.text = departedTimeForLabel
    }
    
    @objc private func presentDatePicker() {
        let actionSheet = UIAlertController(title: "날짜를 선택해주세요\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        let datePickerView = UIView()
        
        actionSheet.view.addSubview(datePickerView)
        datePickerView.addSubview(self.departedDatePicker)
        
        actionSheet.view.snp.makeConstraints {
            $0.height.equalTo(240)
        }
        
        datePickerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview().inset(5)
        }
        
        self.departedDatePicker.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.top.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(30)
        }
        
        actionSheet.addAction(actionCancel)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @objc func searchBusInfo() {
        let departedPlace = BusPlace.allCases[self.selectedDepartureBtn.tag]
        let arrivedPlace = BusPlace.allCases[self.selectedArrivalBtn.tag]
        let selectedBusPlace = SelectedBusPlaceStatus(lastDepartedPlace: nil, nowDepartedPlace: departedPlace, lastArrivedPlace: nil, nowArrivedPlace: arrivedPlace)
        self.inputSubject.send(.searchBusInfo(selectedBusPlace: selectedBusPlace, date: self.departedDatePicker.date, time: self.departedTimePicker.date))
        self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busSearch, .click, "조회"))
    }
    
    private func initializeView() {
        self.selectedDepartureBtn.tag = 0
        self.selectedArrivalBtn.tag = 2
        self.inputSubject.send(.getBusInfo(selectedBusPlace: SelectedBusPlaceStatus(lastDepartedPlace: nil, nowDepartedPlace: .koreatech, lastArrivedPlace: nil, nowArrivedPlace: .terminal)))
        self.departedDatePicker.date = Date()
        let departedDateForBtn = self.departedDatePicker.date.formatDateToMDE()
        let departedDateForlabel = self.departedDatePicker.date.formatDateToYYYYMMDD(separator: "/")
        self.departedDateLabel.text = departedDateForlabel
        self.updateDateBtn(date: departedDateForBtn)
        self.departedTimePicker.date = Date()
        self.departedTimeLabel.text = self.departedTimePicker.date.formatDateToHHMM(isHH: false)
    }
    
    private func getBusRoute(sender: UIButton, lastSelectedTag: Int, nowSelectedTag: Int) {
        let lastBusPlace = BusPlace.allCases[lastSelectedTag]
        let nowSelectedPlace = BusPlace.allCases[nowSelectedTag]
        if sender == self.selectedDepartureBtn {
            let selectedBusPlace = SelectedBusPlaceStatus(lastDepartedPlace: lastBusPlace, nowDepartedPlace: nowSelectedPlace, lastArrivedPlace: nil, nowArrivedPlace: BusPlace.allCases[self.selectedArrivalBtn.tag])
            self.inputSubject.send(.changeBusRoute(selectedBusPlace: selectedBusPlace))
        }
        else {
            let selectedBusPlace = SelectedBusPlaceStatus(lastDepartedPlace: nil, nowDepartedPlace: BusPlace.allCases[self.selectedDepartureBtn.tag], lastArrivedPlace: lastBusPlace, nowArrivedPlace: nowSelectedPlace)
            self.inputSubject.send(.changeBusRoute(selectedBusPlace: selectedBusPlace))
        }
    }
    
    private func mapBusPlaceToTag(busPlace: BusPlace) -> Int {
        switch busPlace {
        case .koreatech:
            return 0
        case .station:
            return 1
        case .terminal:
            return 2
        }
    }
    
    private func updateDepartureAndArrivalText(departure: BusPlace, arrival: BusPlace) {
        
        self.selectedDepartureBtn.tag = mapBusPlaceToTag(busPlace: departure)
        self.selectedArrivalBtn.tag = mapBusPlaceToTag(busPlace: arrival)
        
        for btn in [self.selectedDepartureBtn, self.selectedArrivalBtn] {
            var attributedString = AttributedString.init(stringLiteral: "")
            if btn == self.selectedDepartureBtn {
                attributedString = AttributedString.init(stringLiteral: departure.koreanDescription)
            }
            else {
                attributedString = AttributedString.init(stringLiteral: arrival.koreanDescription)
            }
            var config = UIButton.Configuration.plain()
            
            attributedString.font = .appFont(.pretendardRegular, size: 20)
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium, scale: .medium)
            let imageView = UIImage(systemName: SFSymbols.chevronDown.rawValue, withConfiguration: imageConfig)
            config.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0)
            config.image = imageView
            config.attributedTitle = attributedString
            config.imagePadding = 7
            btn.configuration = config
        }
    }
    
    private func updateDateBtn(date: String) {
        var config = UIButton.Configuration.plain()
        var attributedTitle = AttributedString.init(date)
        attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 20)
        config.attributedTitle = attributedTitle
        self.selectedDateBtn.configuration = config
    }
    
    private func showResultAlert(searchedResult: SearchBusInfoResult) {
        let title: String = "운행 정보 조회"
        let shuttleTime = searchedResult.shuttleTime ?? "운행정보없음"
        let expressTime = searchedResult.expressTime ?? "운행정보없음"
        let commutingTime = searchedResult.commutingTime ?? "운행정보없음"
        let message = "\n학교셔틀:\t\(shuttleTime)\n\n대성고속:\t\(expressTime)\n\n통학버스:\t\(commutingTime)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "닫기",
                                         style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

}

extension SearchBusViewController {
    private func initDropDown() {
        busPlaceDropDown.textColor = .appColor(.neutral600)
        busPlaceDropDown.backgroundColor = .systemBackground
        busPlaceDropDown.setupCornerRadius(8)
        busPlaceDropDown.width = busPlaceDropDown.anchorView?.plainView.bounds.width
        busPlaceDropDown.separatorColor = UIColor.appColor(.neutral200)
        busPlaceDropDown.shadowOffset = CGSize(width: 2, height: 3)
        busPlaceDropDown.dismissMode = .automatic
        busPlaceDropDown.cancelAction = { [weak self] in
            let chevronImageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium, scale: .medium)
            let chevronImageView = UIImage(systemName: SFSymbols.chevronDown.rawValue, withConfiguration: chevronImageConfig)
            self?.selectedDepartureBtn.setImage(chevronImageView, for: .normal)
            self?.selectedArrivalBtn.setImage(chevronImageView, for: .normal)
        }
    }
    
    private func configure() {
        self.selectedDateBtn.addTarget(self, action: #selector(presentDatePicker), for: .touchUpInside)
        self.departedDatePicker.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        self.departedTimePicker.addTarget(self, action: #selector(updateTime), for: .valueChanged)
        self.selectedDepartureBtn.addTarget(self, action: #selector(showBusPlaceOptionsAlert), for: .touchUpInside)
        self.selectedArrivalBtn.addTarget(self, action: #selector(showBusPlaceOptionsAlert), for: .touchUpInside)
        self.searchedDepartureBtn.addTarget(self, action: #selector(searchBusInfo), for: .touchUpInside)
    }
    
    private func setUpViewLayers() {
        [selectedBusPlaceWrappedView, dateChoiceSign, timeChoiceSign, dateBtnWrappedView, timePickerWrappedView, searchAreaWrappedView, departedTimePicker, selectedDateBtn].forEach {
            view.addSubview($0)
        }
        
        selectedBusPlaceWrappedView.addSubview(stackViewForPlace)
        timePickerWrappedView.addSubview(departedTimePicker)
        dateBtnWrappedView.addSubview(selectedDateBtn)
        [departedDateLabel, departedTimeLabel, searchedDepartureBtn].forEach {
            searchAreaWrappedView.addSubview($0)
        }
    }
    
    private func setUpButtons() {
        [selectedDepartureBtn, selectedArrivalBtn].forEach {
            var config = UIButton.Configuration.plain()
            
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium, scale: .medium)
            let imageView = UIImage(systemName: SFSymbols.chevronDown.rawValue, withConfiguration: imageConfig)
            
            var attributedTitle = AttributedString.init("")
            attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 20)
            
            config.attributedTitle = attributedTitle
            config.image = imageView
            config.imagePadding = 4
            config.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0)
            $0.configuration = config
        }
    }
    
    private func setUpLayout() {
        
        selectedBusPlaceWrappedView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        stackViewForPlace.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(selectedBusPlaceWrappedView.snp.centerY)
            $0.top.equalToSuperview().inset(15)
        }
        
        dateBtnWrappedView.snp.makeConstraints {
            $0.leading.trailing.equalTo(0)
            $0.top.equalTo(selectedBusPlaceWrappedView.snp.bottom).offset(32)
            $0.height.equalTo(85)
        }
        
        dateChoiceSign.snp.makeConstraints {
            $0.leading.equalTo(16)
            $0.top.equalTo(selectedBusPlaceWrappedView.snp.bottom).offset(6)
        }
        
        timeChoiceSign.snp.makeConstraints {
            $0.leading.equalTo(16)
            $0.top.equalTo(dateBtnWrappedView.snp.bottom).offset(6)
        }
        
        selectedDateBtn.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        timePickerWrappedView.snp.makeConstraints {
            $0.leading.trailing.equalTo(0)
            $0.top.equalTo(dateBtnWrappedView.snp.bottom).offset(32)
            $0.bottom.equalTo(searchAreaWrappedView.snp.top)
        }
        
        departedTimePicker.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        searchAreaWrappedView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(70)
        }
        
        departedDateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(58)
            $0.top.equalToSuperview().inset(25)
        }
        
        departedTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(departedDateLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
        
        searchedDepartureBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().inset(20)
        }
        
        
    }
}
