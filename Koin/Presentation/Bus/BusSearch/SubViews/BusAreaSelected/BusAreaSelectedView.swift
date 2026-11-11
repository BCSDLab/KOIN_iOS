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
        $0.font = .appFont(.pretendardSemiBold, size: 18)
        $0.textColor = .appColor(.new500)
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(.appImage(asset: .cancel)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .appColor(.neutral800)
        $0.accessibilityLabel = "닫기"
    }

    private let busAreaCollectionView = BusAreaSelectedCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        $0.collectionViewLayout = layout
        $0.contentInset = .init(top: 12, left: 32, bottom: 12, right: 32)
    }

    private let confirmButton = UIButton().then {
        $0.backgroundColor = .appColor(.new500)
        $0.layer.cornerRadius = 20
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
        closeButton.addTarget(self, action: #selector(tapCloseButton), for: .touchUpInside)
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
        let attributeContainer: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(.pretendardSemiBold, size: 16), .foregroundColor: UIColor.appColor(.neutral0)]
        let confirmButtonTitle: String
        if buttonState == .allSelected {
            confirmButtonTitle = "완료"
        }
        else {
            confirmButtonTitle = busRouteType == .arrival ? "출발지 선택하기" : "도착지 선택하기"
        }
        busRouteDescriptionlabel.text = busRouteType == .arrival ? "도착지 선택" : "출발지 선택"
        confirmButton.setAttributedTitle(NSAttributedString(string: confirmButtonTitle, attributes: attributeContainer), for: .normal)
    }

    @objc private func tapCloseButton() {
        delegate?.dismiss(completion: nil)
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
        [busRouteDescriptionlabel, closeButton, busAreaCollectionView, confirmButton].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        // 타이틀 행 66(padding 12 v) → 칩 영역(padding 12 v + 칩 34) → gap 80 → 버튼 48
        busRouteDescriptionlabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(42)
        }
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(busRouteDescriptionlabel)
            // 아이콘 24는 trailing 32 위치 유지, 터치 영역 44
            $0.trailing.equalToSuperview().inset(22)
            $0.width.height.equalTo(44)
        }
        busAreaCollectionView.snp.makeConstraints {
            $0.top.equalTo(busRouteDescriptionlabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(58)
        }
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.top.equalTo(busAreaCollectionView.snp.bottom).offset(80)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(40)
        }
    }

    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        backgroundColor = .systemBackground
    }
}
