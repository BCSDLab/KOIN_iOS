//
//  BusTimetableRouteView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/29/24.
//

import Combine
import Then
import UIKit

final class BusTimetableRouteView: UIView {
    // MARK: - properties
    let busRouteContentHeightPublisher = PassthroughSubject<CGFloat, Never>()
    // MARK: - UI Components
    private let firstBusTimetableRouteCollectionView =  BusTimetableRouteCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    private let secondBusTimetableRouteCollectionView = BusTimetableRouteCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    private let firstBusRouteGuideLabel = UILabel().then {
        $0.textColor = .appColor(.neutral600)
        $0.font = .appFont(.pretendardRegular, size: 16)
    }
    private let secondBusRouteGuideLabel = UILabel().then {
        $0.textColor = .appColor(.neutral600)
        $0.font = .appFont(.pretendardRegular, size: 16)
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        commonInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        configureView()
    }
    
    func setBusType(busType: BusType, firstRouteList: [String], secondRouteList: [String]?) {
        let isCityBus = (busType == .cityBus)
        let isExpressBus = (busType == .expressBus)
        let shouldShowFirstLabel = isCityBus || isExpressBus
       
        firstBusRouteGuideLabel.isHidden = !shouldShowFirstLabel
        secondBusRouteGuideLabel.isHidden = !isCityBus
        secondBusTimetableRouteCollectionView.isHidden = !isCityBus
      
        firstBusRouteGuideLabel.text = isCityBus ? "운행" : (isExpressBus ? "기점" : "")
        secondBusRouteGuideLabel.text = isCityBus ? "노선" : ""
      
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.firstBusTimetableRouteCollectionView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(shouldShowFirstLabel ? 68 : 24)
            }
        }
      
        busRouteContentHeightPublisher.send(isCityBus ? 104 : 62)
        
        firstBusTimetableRouteCollectionView.configure(routeList: firstRouteList)
        secondBusTimetableRouteCollectionView.configure(routeList: secondRouteList ?? [])
    }
}

extension BusTimetableRouteView {
    private func setUpLayouts() {
        [firstBusRouteGuideLabel, secondBusRouteGuideLabel, firstBusTimetableRouteCollectionView, secondBusTimetableRouteCollectionView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        firstBusRouteGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(28)
            $0.height.equalTo(26)
        }
        secondBusRouteGuideLabel.snp.makeConstraints {
            $0.top.equalTo(firstBusRouteGuideLabel.snp.bottom).offset(18)
            $0.leading.equalTo(firstBusRouteGuideLabel)
            $0.width.equalTo(28)
            $0.height.equalTo(26)
        }
        firstBusTimetableRouteCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(68)
            $0.centerY.equalTo(firstBusRouteGuideLabel)
            $0.height.equalTo(34)
            $0.trailing.equalToSuperview().inset(24)
        }
        secondBusTimetableRouteCollectionView.snp.makeConstraints {
            $0.leading.equalTo(secondBusRouteGuideLabel.snp.trailing).offset(16)
            $0.centerY.equalTo(secondBusRouteGuideLabel)
            $0.height.equalTo(34)
            $0.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        backgroundColor = .appColor(.neutral100)
    }
}
