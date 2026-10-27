//
//  BusAreaSelectedView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class BusAreaSelectedView: UIView, KoinBottomSheetContent {
    weak var delegate: KoinBottomSheetDelegate?
    //MARK: - Properties
    private let onDepartureBusAreaSelected: (BusPlace) -> Void
    private let onArrivalBusAreaSelected: (BusPlace) -> Void
    private var buttonState: BusAreaButtonState = .departureSelect
    private var busRouteType: BusAreaButtonType = .departure

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
    init(
        onDepartureBusAreaSelected: @escaping (BusPlace) -> Void,
        onArrivalBusAreaSelected: @escaping (BusPlace) -> Void
    ) {
        self.onDepartureBusAreaSelected = onDepartureBusAreaSelected
        self.onArrivalBusAreaSelected = onArrivalBusAreaSelected
        super.init(frame: .zero)
        configureView()
        confirmButton.addTarget(self, action: #selector(tapConfirmButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



}

extension BusAreaSelectedView {
    func configure(
        busAreaLists: [(BusPlace, Bool)],
        buttonState: BusAreaButtonState,
        departure: BusPlace?,
        arrival: BusPlace?
    ) {
        busAreaCollectionView.departureBusAreaPublisher.send(departure)
        busAreaCollectionView.arrivalBusAreaPublisher.send(arrival)

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
        let departure = busAreaCollectionView.departureBusAreaPublisher.value
        let arrival = busAreaCollectionView.arrivalBusAreaPublisher.value
        let routeType = busRouteType
        let applySelection: () -> Void = { [onDepartureBusAreaSelected, onArrivalBusAreaSelected] in
            if let departure, routeType == .departure {
                onDepartureBusAreaSelected(departure)
            }
            if let arrival, routeType == .arrival {
                onArrivalBusAreaSelected(arrival)
            }
        }
        if buttonState == .allSelected {
            delegate?.dismiss(completion: applySelection)
        } else {
            applySelection()
            buttonState = .allSelected
            busRouteType = busRouteType == .arrival ? .departure : .arrival
        }
        let busAreaList: [(BusPlace, Bool)] = [(.koreatech, false), (.station, false), (.terminal, false)]
        busAreaCollectionView.configure(busAreaLists: busAreaList, buttonState: busRouteType)
        setUpView(buttonState: .allSelected)
    }

}

extension BusAreaSelectedView {

    private func setUpLayOuts() {
        [busRouteDescriptionlabel, busAreaCollectionView, confirmButton, separateView].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        busRouteDescriptionlabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(29)
        }
        busAreaCollectionView.snp.makeConstraints {
            $0.top.equalTo(separateView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160).priority(500)
        }
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.top.equalTo(busAreaCollectionView.snp.bottom)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(40)
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
        backgroundColor = .systemBackground
    }
}
