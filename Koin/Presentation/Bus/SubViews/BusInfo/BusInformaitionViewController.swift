//
//  BusInformationViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/03/30.
//

import Combine
import DropDown
import SnapKit
import UIKit

final class BusInformationViewController: UIViewController {
    // MARK: - Properties
    private let inputSubject: PassthroughSubject<BusViewModel.Input, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: BusViewModel
    private var timer = Timer()
    
    // MARK: - UI Components
    //<한기대에서 야우리로 갑니다> 버튼 Wrapper
    private let busPlaceDropDown = DropDown()
    private let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    //출발지 선택 버튼 (e.g 한기대)
    private let selectedDepartureBtn: UIButton = {
        let button = UIButton()
    
        button.semanticContentAttribute = .forceRightToLeft
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        return button
    }()
    
    //도착지 선택 버튼 (e.g 야우리)
    private let selectedArrivalBtn: UIButton = {
        let button = UIButton()
        
        button.semanticContentAttribute = .forceRightToLeft
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .leading
        button.tintColor = .black
        return button
    }()
    
    //<한기대에서 야우리 갑니다> stackview
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        let label1 = UILabel()
        let label2 = UILabel()
        label1.text = "에서 "
        label2.text = "갑니다"
        
        label1.font = UIFont.appFont(.pretendardRegular, size: 20)
        label2.font = UIFont.appFont(.pretendardRegular, size: 20)
        
        label1.textColor = UIColor.black
        label2.textColor = UIColor.black
        
        [selectedDepartureBtn, label1, selectedArrivalBtn, label2].forEach{
            stackView.addArrangedSubview($0)
        }
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        
        return stackView
    }()
    
    
    //도착정보를 띄워주는 collectionView
    private let busInfoCollectionView: BusInformationCollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 245)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        layout.scrollDirection = .vertical
        let collectionview = BusInformationCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.backgroundColor = .systemBackground
        collectionview.register(BusInformationCollectionViewCell.self, forCellWithReuseIdentifier: BusInformationCollectionViewCell.identifier)
        
        return collectionview
    }()
    
    // MARK: - Initialization
    init(viewModel: BusViewModel) {
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
        setUpViewLayers()
        setUpButtons()
        setUpLayout()
        initDropDown()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initializeDepartureAndArrival()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer.invalidate()
    }
    
    private func bind() {
        let output = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        output.receive(on: DispatchQueue.main)
            .sink { [weak self] event in
            switch event {
            case .updateBusRoute(let departure, let arrival):
                self?.updateDepartureAndArrivalText(departure: departure, arrival: arrival)
            case .updateBusInfo(let busInformationModel):
                self?.updateBusInformation(busInformationModel: busInformationModel)
            default:
                print("")
            }
            
        }.store(in: &cancellables)
    }
}

extension BusInformationViewController {
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
                self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busDeparture, EventParameter.EventCategory.click, item))
            }
            else if sender == self.selectedArrivalBtn {
                self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.busArrival, EventParameter.EventCategory.click, item))
            }
            let lastBtnTag = sender.tag
            
            self.getBusRoute(sender: sender, lastSelectedTag: lastBtnTag, nowSelectedTag: index)
            let chevronImageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium, scale: .medium)
            let chevronImageView = UIImage(systemName: SFSymbols.chevronDown.rawValue, withConfiguration: chevronImageConfig)
            sender.setImage(chevronImageView, for: .normal)
        }
        busPlaceDropDown.show()
    }

    private func getBusRoute(sender: UIButton, lastSelectedTag: Int, nowSelectedTag: Int) {
        let lastBusPlace = BusPlace.allCases[lastSelectedTag]
        let nowSelectedPlace = BusPlace.allCases[nowSelectedTag]
        if sender == self.selectedDepartureBtn {
            let selectedBusPlace = SelectedBusPlaceStatus(lastDepartedPlace: lastBusPlace, nowDepartedPlace: nowSelectedPlace, lastArrivedPlace: nil, nowArrivedPlace: BusPlace.allCases[self.selectedArrivalBtn.tag])
            self.inputSubject.send(.getBusInfo(selectedBusPlace: selectedBusPlace))
        }
        else {
            let selectedBusPlace = SelectedBusPlaceStatus(lastDepartedPlace: nil, nowDepartedPlace: BusPlace.allCases[self.selectedDepartureBtn.tag], lastArrivedPlace: lastBusPlace, nowArrivedPlace: nowSelectedPlace)
            self.inputSubject.send(.getBusInfo(selectedBusPlace: selectedBusPlace))
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
    
    private func initializeDepartureAndArrival() {
        self.selectedDepartureBtn.tag = 0
        self.selectedArrivalBtn.tag = 2
        self.inputSubject.send(.getBusInfo(selectedBusPlace: SelectedBusPlaceStatus(lastDepartedPlace: nil, nowDepartedPlace: .koreatech, lastArrivedPlace: nil, nowArrivedPlace: .terminal)))
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] _ in
            guard let self = self else {return}
            let departedPlace = BusPlace.allCases[self.selectedDepartureBtn.tag]
            let arrivedplace = BusPlace.allCases[self.selectedArrivalBtn.tag]
            self.inputSubject.send(.getBusInfo(selectedBusPlace: SelectedBusPlaceStatus(lastDepartedPlace: nil, nowDepartedPlace: departedPlace, lastArrivedPlace: nil, nowArrivedPlace: arrivedplace)))
        })
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

    private func updateBusInformation(busInformationModel: [BusCardInformation]) {
        busInfoCollectionView.setBusInformationList(busInformationModel)
    }
}

//view setting
extension BusInformationViewController {
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

    //view, data setup
    private func setUpViewLayers() {
        [wrapperView, stackView, busInfoCollectionView].forEach {
            view.addSubview($0)
        }
        
        self.selectedDepartureBtn.addTarget(self, action: #selector(showBusPlaceOptionsAlert), for: .touchUpInside)
        self.selectedArrivalBtn.addTarget(self, action: #selector(showBusPlaceOptionsAlert), for: .touchUpInside)
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
    
    //layout setup
    private func setUpLayout() {
        wrapperView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(15)
        }
        
        busInfoCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(wrapperView.snp.bottom)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
    }
}


