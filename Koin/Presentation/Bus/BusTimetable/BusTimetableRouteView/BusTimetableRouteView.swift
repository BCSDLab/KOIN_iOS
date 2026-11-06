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
    let busFilterIdxPublisher = CurrentValueSubject<(Int, Int?), Never>((0, nil))
    let firstFilterPublisher = PassthroughSubject<String, Never>()
    let secondFilterPublisher = PassthroughSubject<String, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let firstBusTimetableRouteCollectionView =  BusTimetableRouteCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    private let secondBusTimetableRouteCollectionView = BusTimetableRouteCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
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
        
        firstBusTimetableRouteCollectionView.filterIdxPublisher.sink { [weak self] index, value in
            if let secondFilterIdx = self?.busFilterIdxPublisher.value.1 {
                self?.busFilterIdxPublisher.send((index, secondFilterIdx))
            }
            else {
                self?.busFilterIdxPublisher.send((index, nil))
            }
            self?.firstFilterPublisher.send(value)
        }.store(in: &subscriptions)
        
        secondBusTimetableRouteCollectionView.filterIdxPublisher.sink { [weak self] index, value in
            guard let self = self else { return }
            self.busFilterIdxPublisher.send((self.busFilterIdxPublisher.value.0, index))
            self.secondFilterPublisher.send(value)
        }.store(in: &subscriptions)
    }
    
    /// 칩 행 높이 58(칩 34 + 상하 12). 시내버스는 노선 행 + 방면 행 2줄.
    static let rowHeight: CGFloat = 58
    
    static func height(for busType: BusType) -> CGFloat {
        busType == .cityBus ? rowHeight * 2 : rowHeight
    }
    
    func setBusType(busType: BusType, firstRouteList: [String], secondRouteList: [String]?) {
        let isCityBus = (busType == .cityBus)
        secondBusTimetableRouteCollectionView.isHidden = !isCityBus
        
        firstBusTimetableRouteCollectionView.configure(routeList: firstRouteList)
        secondBusTimetableRouteCollectionView.configure(routeList: secondRouteList ?? [])
        
        if isCityBus {
            busFilterIdxPublisher.send((0, 0))
        }
        else {
            busFilterIdxPublisher.send((0, nil))
        }
    }
}

extension BusTimetableRouteView {
    private func setUpLayouts() {
        [firstBusTimetableRouteCollectionView, secondBusTimetableRouteCollectionView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        firstBusTimetableRouteCollectionView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(Self.rowHeight)
        }
        secondBusTimetableRouteCollectionView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(Self.rowHeight)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        backgroundColor = .appColor(.neutral0)
    }
}
