//
//  BusTimetableViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/03/30.
//

import Combine
import DropDown
import SnapKit
import UIKit

final class BusTimetableViewController: UIViewController {
    
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    private var inputSubject: PassthroughSubject<BusViewModel.Input, Never> = .init()
    private let viewModel: BusViewModel
    private var selectedBtnType: BusType = .shuttleBus
    // MARK: - UI Components
    private let busFilterDropDown = DropDown()
    //시간표 검색 헤더
    private let timetableHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    //버스 종류 고르는 버튼 넣을 스택뷰(학교셔틀, 대성고속, 시내버스)
    private lazy var busTypeBtnWrapper: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        [shuttleBtn, expressBtn, cityBusBtn].forEach{
            stackView.addArrangedSubview($0)
        }
        return stackView
    }()
    
    //e.g)천안 등교/하교, 터미널과 같은 선택지를 고르는 filter들을 감싸는 stackview
    private lazy var busFilterWrappedView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = 32
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        [firstBusFilterBtn, secondBusFilterBtn].forEach{
            stackView.addArrangedSubview($0)
        }
        return stackView
    }()
    
    //셔틀버스 버튼
    private let shuttleBtn: UIButton = {
        let button = UIButton()
        button.isSelected = true
        button.changesSelectionAsPrimaryAction = true
        return button
    }()
    
    //대성고속 보튼
    private let expressBtn: UIButton = {
        let button = UIButton()
        button.changesSelectionAsPrimaryAction = true
        return button
    }()
    
    //시내버스 버튼
    private let cityBusBtn: UIButton = {
        let button = UIButton()
        button.changesSelectionAsPrimaryAction = true
        return button
    }()
    
    //등교 종류 버튼
    private let firstBusFilterBtn: UIView = {
        let view = UIView()
        return view
    }()
    
    //장소 버튼
    private let secondBusFilterBtn: UIView = {
        let view = UIView()
        return view
    }()
    
    private let firstBusFilterLabel: UILabel = {
        let label = UILabel()
        label.text = "첫번째"
        label.font = UIFont.appFont(.pretendardMedium, size: 16)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let secondBusFilterLabel: UILabel = {
        let label = UILabel()
        label.text = "두번째"
        label.font = UIFont.appFont(.pretendardMedium, size: 16)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let image = UIImage(systemName: SFSymbols.chevronDown.rawValue)?.withConfiguration(UIImage.SymbolConfiguration(font: .appFont(.pretendardBold, size: 13)))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .appColor(.neutral600)
        return imageView
    }()
    
    //시간표 테이블
    private let busTimetableTableview: BusTimetableTableView = {
        let tableview = BusTimetableTableView(frame: .zero, style: .plain)
        tableview.separatorColor = .gray
        tableview.sectionHeaderTopPadding = 0
        tableview.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        tableview.allowsSelection = false
        tableview.separatorColor = .appColor(.neutral300)
        return tableview
        
    }()
    
    // MARK: - Initialization
    init(viewModel: BusViewModel, busType: BusType) {
        self.viewModel = viewModel
        self.selectedBtnType = busType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setUpViewLayers()
        setUpLayout()
        setUpButtons()
        setUpFilterButtons()
        configure()
        initializeView(selectedBtnType: selectedBtnType)
        initDropDown()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        initializeView(selectedBtnType: .shuttleBus)
    }
    
    private func bind() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        output.receive(on: DispatchQueue.main)
            .sink { [weak self] event in
            switch event {
            case .updateBusFirstFilter(let busCourseModel, let busType):
                self?.showFirstFilterOptions(busCourses: busCourseModel, busType: busType)
            case .updateBusSecondFilter(let busRouteModel):
                self?.showSecondFilterOptions(busRouteModel: busRouteModel)
            case .updateBusTimetable(let busTimetableModel, let busType):
                self?.updateBusTimetable(timetable: busTimetableModel, busType: busType)
            case .updateCityBusFilters(let cityBusFilters):
                self?.showCityBusFiltersOptions(cityBusFilters: cityBusFilters)
            default:
                print("")
            }
            
        }.store(in: &cancellables)
    }
    
   
}

extension BusTimetableViewController {
    @objc private func tapShuttleBtn() {
        self.secondBusFilterBtn.isHidden = false
        self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busTimetable, EventParameter.EventCategory.click, "학교셔틀"))
        self.firstBusFilterBtn.tag = 4
        self.secondBusFilterBtn.tag = 0
        self.inputSubject.send(.getBusTimetable(busType: .shuttleBus, firstBusFilterIdx: 4, secondBusFilterIdx: 0))
    }
    
    @objc private func tapExpressBtn() {
        self.secondBusFilterBtn.isHidden = true
        self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busTimetable, EventParameter.EventCategory.click, "대성고속"))
        self.firstBusFilterBtn.tag = 0
        self.inputSubject.send(.getBusTimetable(busType: .expressBus, firstBusFilterIdx: 0, secondBusFilterIdx: nil))
    }
    
    @objc private func tapCityBusBtn() {
        self.secondBusFilterBtn.isHidden = false
        self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busTimetable, EventParameter.EventCategory.click, "시내버스"))
        self.firstBusFilterBtn.tag = 0
        self.secondBusFilterBtn.tag = 0
        self.inputSubject.send(.getBusTimetable(busType: .cityBus, firstBusFilterIdx: 0, secondBusFilterIdx: 0))
    }
    
    @objc private func changeOtherButtonState(sender: UIButton) {
        
        if sender == shuttleBtn {
            expressBtn.isSelected = false
            cityBusBtn.isSelected = false
        }
        else if sender == expressBtn {
            shuttleBtn.isSelected = false
            cityBusBtn.isSelected = false
        }
        else{
            shuttleBtn.isSelected = false
            expressBtn.isSelected = false
        }
        sender.isSelected = true
    }
    
    @objc private func tapBusFirstFilter(sender: UIView) {
        if shuttleBtn.isSelected == true {
            self.inputSubject.send(.getBusFirstFilter)
        }
        else if expressBtn.isSelected == true {
            if self.firstBusFilterBtn.tag == 0 {
                self.inputSubject.send(.getBusTimetable(busType: .expressBus, firstBusFilterIdx: 1, secondBusFilterIdx: nil))
                self.firstBusFilterBtn.tag = 1
            }
            else {
                self.inputSubject.send(.getBusTimetable(busType: .expressBus, firstBusFilterIdx: 0, secondBusFilterIdx: nil))
                self.firstBusFilterBtn.tag = 0
            }
        }
        else {
            if self.firstBusFilterBtn.tag == 0 {
                self.inputSubject.send(.getBusTimetable(busType: .cityBus, firstBusFilterIdx: 1, secondBusFilterIdx: self.secondBusFilterBtn.tag))
                self.firstBusFilterBtn.tag = 1
            }
            else {
                self.inputSubject.send(.getBusTimetable(busType: .cityBus, firstBusFilterIdx: 0, secondBusFilterIdx: self.secondBusFilterBtn.tag))
                self.firstBusFilterBtn.tag = 0
            }
        }
    }
    
    @objc private func tapBusSecondFilter(sender: UIView) {
        if shuttleBtn.isSelected == true {
            self.inputSubject.send(.getBusSecondFilter(busType: .shuttleBus, firstBusFilterIdx: self.firstBusFilterBtn.tag))
        }
        else if cityBusBtn.isSelected == true {
            self.inputSubject.send(.getBusSecondFilter(busType: .cityBus, firstBusFilterIdx: self.firstBusFilterBtn.tag))
        }
        self.chevronImageView.image = UIImage(systemName: SFSymbols.chevronUp.rawValue)?.withConfiguration(UIImage.SymbolConfiguration(font: .appFont(.pretendardBold, size: 13)))
    }
    
    private func initializeView(selectedBtnType: BusType) {
        switch selectedBtnType {
        case .shuttleBus:
            self.firstBusFilterBtn.tag = 4
            self.secondBusFilterBtn.tag = 0
            self.inputSubject.send(.getBusTimetable(busType: .shuttleBus, firstBusFilterIdx: 4, secondBusFilterIdx: 0))
            shuttleBtn.isSelected = true
            expressBtn.isSelected = false
            cityBusBtn.isSelected = false
        case .expressBus:
            self.firstBusFilterBtn.tag = 0
            self.secondBusFilterBtn.isHidden = true
            self.inputSubject.send(.getBusTimetable(busType: .expressBus, firstBusFilterIdx: 0, secondBusFilterIdx: nil))
            expressBtn.isSelected = true
            shuttleBtn.isSelected = false
            cityBusBtn.isSelected = false
        default:
            self.inputSubject.send(.getBusTimetable(busType: .cityBus, firstBusFilterIdx: 0, secondBusFilterIdx: self.secondBusFilterBtn.tag))
            self.firstBusFilterBtn.tag = 0
            cityBusBtn.isSelected = true
            expressBtn.isSelected = false
            shuttleBtn.isSelected = false
        }
    }

    private func updateBusTimetable(timetable: BusTimetableInfo, busType: BusType) {
        self.firstBusFilterLabel.text = timetable.courseName
        switch busType {
        case .shuttleBus:
            let header = ("승차장소", "시간")
            self.secondBusFilterLabel.text = timetable.routeName
            busTimetableTableview.setBusTimetableList(busTimetableModel: timetable, busTimetableHeader: header)
        case .expressBus:
            let header = ("출발시간", "도착시간")
            busTimetableTableview.setBusTimetableList(busTimetableModel: timetable, busTimetableHeader: header)
        default:
            let header = ("오전", "오후")
            self.secondBusFilterLabel.text = timetable.routeName
            busTimetableTableview.setBusTimetableList(busTimetableModel: timetable, busTimetableHeader: header)
        }
    
    }
    
    private func showFirstFilterOptions(busCourses: [BusCourseInfo], busType: BusType) {
        var itemList: [String] = []
        for busCourse in busCourses {
            itemList.append(busCourse.busCourse)
        }
        busFilterDropDown.dataSource = itemList
        busFilterDropDown.anchorView = self.firstBusFilterBtn
        busFilterDropDown.bottomOffset = CGPoint(x: 0, y: firstBusFilterBtn.bounds.height)
        switch busType {
        case .shuttleBus:
            busFilterDropDown.selectionAction = { [weak self] (index, item) in
                self?.firstBusFilterLabel.text = item
                self?.firstBusFilterBtn.tag = index
                self?.inputSubject.send(.getBusTimetable(busType: .shuttleBus, firstBusFilterIdx: index, secondBusFilterIdx: 0))
            }
        default:
            busFilterDropDown.selectionAction = { [weak self] (index, item) in
                self?.firstBusFilterLabel.text = item
                self?.inputSubject.send(.getBusTimetable(busType: .expressBus, firstBusFilterIdx: index, secondBusFilterIdx: nil))
            }
        }
        busFilterDropDown.show()
    }
    
    private func showSecondFilterOptions(busRouteModel: [String]) {
        busFilterDropDown.dataSource = busRouteModel
        busFilterDropDown.anchorView = self.secondBusFilterBtn
        busFilterDropDown.bottomOffset = CGPoint(x: 0, y: secondBusFilterBtn.bounds.height)
        busFilterDropDown.selectionAction = { [weak self] (index, item) in
            self?.chevronImageView.image = UIImage(systemName: SFSymbols.chevronDown.rawValue)?.withConfiguration(UIImage.SymbolConfiguration(font: .appFont(.pretendardBold, size: 13)))
            self?.secondBusFilterLabel.text = busRouteModel[index]
            self?.inputSubject.send(.getBusTimetable(busType: .shuttleBus, firstBusFilterIdx: self?.firstBusFilterBtn.tag ?? 0, secondBusFilterIdx: index))
            
        }
        busFilterDropDown.show()
    }
    
    private func showCityBusFiltersOptions(cityBusFilters: [CityBusCourseInfo]) {
        var itemList: [String] = []
        for busFilter in cityBusFilters {
            itemList.append("\(busFilter.busNumber.rawValue)번")
        }
        busFilterDropDown.anchorView = self.secondBusFilterBtn
        busFilterDropDown.bottomOffset = CGPoint(x: 0, y: secondBusFilterBtn.bounds.height)
    
        busFilterDropDown.dataSource = itemList
        busFilterDropDown.selectionAction = { [weak self] (index, item) in
            self?.chevronImageView.image = UIImage(systemName: SFSymbols.chevronDown.rawValue)?.withConfiguration(UIImage.SymbolConfiguration(font: .appFont(.pretendardBold, size: 13)))
            self?.secondBusFilterLabel.text = itemList[index]
            self?.secondBusFilterBtn.tag = index
            self?.inputSubject.send(.getBusTimetable(busType: .cityBus, firstBusFilterIdx: self?.firstBusFilterBtn.tag ?? 0, secondBusFilterIdx: index))
        }
        busFilterDropDown.show()
    }

}

extension BusTimetableViewController {
    func configure() {
        shuttleBtn.addTarget(self, action: #selector(changeOtherButtonState), for: .touchUpInside)
        expressBtn.addTarget(self, action: #selector(changeOtherButtonState), for: .touchUpInside)
        cityBusBtn.addTarget(self, action: #selector(changeOtherButtonState), for: .touchUpInside)
        expressBtn.addTarget(self, action: #selector(tapExpressBtn), for: .touchUpInside)
        shuttleBtn.addTarget(self, action: #selector(tapShuttleBtn), for: .touchUpInside)
        cityBusBtn.addTarget(self, action: #selector(tapCityBusBtn), for: .touchUpInside)
        
        let firstBusFilterTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBusFirstFilter))
        firstBusFilterBtn.addGestureRecognizer(firstBusFilterTapGesture)
        firstBusFilterBtn.isUserInteractionEnabled = true
        
        let secondBusFilterTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBusSecondFilter))
        secondBusFilterBtn.addGestureRecognizer(secondBusFilterTapGesture)
        secondBusFilterBtn.isUserInteractionEnabled = true
    }
    
    private func initDropDown() {
        busFilterDropDown.textColor = .appColor(.neutral600)
        busFilterDropDown.backgroundColor = .systemBackground
        busFilterDropDown.setupCornerRadius(8)
        busFilterDropDown.width = busFilterDropDown.anchorView?.plainView.bounds.width
        busFilterDropDown.separatorColor = UIColor.appColor(.neutral200)
        busFilterDropDown.shadowOffset = CGSize(width: 2, height: 3)
        busFilterDropDown.dismissMode = .automatic
        busFilterDropDown.cancelAction = { [weak self] in
            self?.chevronImageView.image = UIImage(systemName: SFSymbols.chevronDown.rawValue)?.withConfiguration(UIImage.SymbolConfiguration(font: .appFont(.pretendardBold, size: 13)))
            
        }
    }
    
    func setUpViewLayers() {
        self.view.addSubview(timetableHeaderView)
        self.view.addSubview(busTimetableTableview)
        secondBusFilterBtn.addSubview(chevronImageView)
        timetableHeaderView.addSubview(busTypeBtnWrapper)
        timetableHeaderView.addSubview(busFilterWrappedView)
        self.firstBusFilterBtn.addSubview(firstBusFilterLabel)
        self.secondBusFilterBtn.addSubview(secondBusFilterLabel)
    }
    
    func setUpButtons() {
        // 버스 종류 선택 버튼 set up
        let busTypes: [BusType: UIButton] = [.shuttleBus: self.shuttleBtn, .expressBus: self.expressBtn, .cityBus: self.cityBusBtn]
        let busTypeBtnColors: [UIColor: UIButton] = [.appColor(.bus1): self.shuttleBtn, .appColor(.bus2): self.expressBtn, .appColor(.bus3): self.cityBusBtn]
        for busType in busTypes {
            let config = setUpBusTypeButtons(busType: busType.key)
            busType.value.configuration = config
        }
        
        for btnColor in busTypeBtnColors {
            let handler: UIButton.ConfigurationUpdateHandler = { btn in
                switch btn.state {
                case .selected:
                    btn.configuration?.background.backgroundColor = btnColor.key.withAlphaComponent(1)
                default:
                    btn.configuration?.background.backgroundColor = btnColor.key.withAlphaComponent(0.4)
                }
            }
            btnColor.value.configurationUpdateHandler = handler
        }
    }
    
    func setUpBusTypeButtons(busType: BusType) -> UIButton.Configuration {
        var config = UIButton.Configuration.tinted()
        var attributedTitle = AttributedString.init(busType.koreanDescription)
        attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 15)
        
        config.baseForegroundColor = .white
        config.attributedTitle = attributedTitle
        config.buttonSize = .medium
        config.background.cornerRadius = 25
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15)
        
        return config
    }
    
    func setUpFilterButtons() {
        [firstBusFilterBtn, secondBusFilterBtn].forEach { view in
            view.backgroundColor = .appColor(.neutral50)
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            view.layer.cornerRadius = 8
        }
    }
    
    func setUpLayout() {
        
        firstBusFilterBtn.snp.makeConstraints{
            
            $0.leading.equalToSuperview()
            $0.height.equalTo(40)
            $0.trailing.equalTo(firstBusFilterLabel.snp.trailing).offset(11)
        }
        
        secondBusFilterBtn.snp.makeConstraints{
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
            $0.leading.equalTo(secondBusFilterLabel.snp.leading).offset(-16)
        }
        
        firstBusFilterLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        secondBusFilterLabel.snp.makeConstraints {
            $0.trailing.equalTo(chevronImageView.snp.trailing).inset(20)
            $0.centerY.equalToSuperview()
        }
        
        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(11)
            $0.centerY.equalToSuperview()
        }
        
        timetableHeaderView.snp.makeConstraints{
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(145)
        }
        
        busTypeBtnWrapper.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(25)
        }
        
        busFilterWrappedView.snp.makeConstraints{
          
            $0.leading.equalTo(31)
            $0.trailing.equalToSuperview().inset(31)
            $0.top.equalTo(busTypeBtnWrapper.snp.bottom).offset(25)
        }
        
        busTimetableTableview.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.top.equalTo(timetableHeaderView.snp.bottom)
            
        }
    }
    
    
}
