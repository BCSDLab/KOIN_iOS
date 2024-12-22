//
//  BusAreaSelectedViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import Then
import UIKit

final class BusAreaSelectedViewController: UIViewController {
    //MARK: - Properties
    let departureBusAreaPublisher = PassthroughSubject<BusPlace, Never>()
    let arrivalBusAreaPublisher = PassthroughSubject<BusPlace, Never>()
    let dismissWithoutConfirmPublisher = PassthroughSubject<((BusPlace?, BusPlace?), Any?), Never>()
    private var buttonState: BusAreaButtonState = .departureSelect
    private var busRouteType: BusAreaButtonType = .departure
    private var subscriptions = Set<AnyCancellable>()
    
    //MARK: - UI Components
    private let busRouteDescriptionlabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let busAreaCollectionView = BusAreaSelectedCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 14
        $0.collectionViewLayout = layout
        $0.contentInset = .init(top: 16, left: 32, bottom: 16, right: 32)
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    private let confirmButton = UIButton().then {
        $0.backgroundColor = .appColor(.primary500)
        $0.layer.cornerRadius = 4
    }
    
    //MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        confirmButton.addTarget(self, action: #selector(tapConfirmButton), for: .touchUpInside)
        
        dismissWithoutConfirmPublisher.sink { [weak self] busPlace, currentBusPlace in
            let departure = busPlace.0
            let arrival = busPlace.1
            if departure != self?.busAreaCollectionView.departureBusAreaPublisher.value {
                self?.busAreaCollectionView.departureBusAreaPublisher.send(departure)
            }
            
            if arrival != self?.busAreaCollectionView.arrivalBusAreaPublisher.value {
                self?.busAreaCollectionView.arrivalBusAreaPublisher.send(arrival)
            }
            
            if (departure != nil && self?.busRouteType == .arrival) || (departure == nil && self?.busRouteType == .departure) {
                self?.busRouteType = departure != nil ? .departure : .arrival
                self?.buttonState = departure != nil ? .departureSelect : .arrivalSelect
            }
        
        }.store(in: &subscriptions)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("DismissBusAreaSelectedView"), object: busRouteType, userInfo: nil)
    }
}

extension BusAreaSelectedViewController {
    func configure(busAreaLists: [(BusPlace, Bool)], buttonState: BusAreaButtonState) {
        if buttonState == .departureSelect {
            busRouteType = .departure
        }
        else {
            busRouteType = .arrival
        }
        if (busAreaCollectionView.departureBusAreaPublisher.value != nil && busRouteType == .arrival) || (busAreaCollectionView.arrivalBusAreaPublisher.value != nil && busRouteType == .departure) {
            self.buttonState = .allSelected
        }
        setUpView(buttonState: self.buttonState)
        busAreaCollectionView.configure(busAreaLists: busAreaLists, buttonState: busRouteType)
    }
    
    func swap(departure: BusPlace, arrival: BusPlace) {
        busAreaCollectionView.departureBusAreaPublisher.send(arrival)
        busAreaCollectionView.arrivalBusAreaPublisher.send(departure)
    }
    
    private func setUpView(buttonState: BusAreaButtonState) {
        let attributeContainer: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(.pretendardMedium, size: 15), .foregroundColor: UIColor.appColor(.neutral0)]
        let confirmButtonTitle: String
        if buttonState == .allSelected {
            
            confirmButtonTitle = "조회하기"
        }
        else {
            confirmButtonTitle = busRouteType == .arrival ? "출발지 선택하기" : "도착지 선택하기"
        }
        busRouteDescriptionlabel.text = busRouteType == .arrival ? "목적지가 어디인가요?" : "어디서 출발하시나요?"
        confirmButton.setAttributedTitle(NSAttributedString(string: confirmButtonTitle, attributes: attributeContainer), for: .normal)
    }
    
    @objc private func tapConfirmButton() {
        if let departure = busAreaCollectionView.departureBusAreaPublisher.value, busRouteType == .departure {
            departureBusAreaPublisher.send(departure)
        }
        
        if let arrival = busAreaCollectionView.arrivalBusAreaPublisher.value, busRouteType == .arrival {
            arrivalBusAreaPublisher.send(arrival)
        }
        if buttonState == .allSelected {
            dismissView()
        }
        else {
            buttonState = .allSelected
            busRouteType = busRouteType == .arrival ? .departure : .arrival
        }
        let busAreaList: [(BusPlace, Bool)] = [(.koreatech, false), (.station, false), (.terminal, false)]
        busAreaCollectionView.configure(busAreaLists: busAreaList, buttonState: busRouteType)
        setUpView(buttonState: .allSelected)
    }
}

extension BusAreaSelectedViewController {
    
    private func setUpLayOuts() {
        [busRouteDescriptionlabel, busAreaCollectionView, confirmButton, separateView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busRouteDescriptionlabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(32)
        }
        busAreaCollectionView.snp.makeConstraints {
            $0.top.equalTo(separateView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.top.equalTo(busAreaCollectionView.snp.bottom)
            $0.height.equalTo(48)
        }
        separateView.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(busRouteDescriptionlabel.snp.bottom).offset(12)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

