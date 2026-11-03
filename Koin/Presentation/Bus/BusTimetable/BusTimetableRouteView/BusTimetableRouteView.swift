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
    
    /// 칩 행 높이(칩 34 + 상하 padding). 시내버스는 노선 행 + 방면 행 2줄.
    static func height(for busType: BusType) -> CGFloat {
        switch busType {
        case .shuttleBus: return 34 + 8 * 2
        case .cityBus: return (34 + 12 * 2) * 2
        default: return 34 + 12 * 2
        }
    }
    
    func setBusType(busType: BusType, firstRouteList: [String], secondRouteList: [String]?) {
        let isCityBus = (busType == .cityBus)
        let verticalPadding: CGFloat = busType == .shuttleBus ? 8 : 12
        secondBusTimetableRouteCollectionView.isHidden = !isCityBus
        
        firstBusTimetableRouteCollectionView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(verticalPadding)
        }
        
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
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(34)
        }
        secondBusTimetableRouteCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(34)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        backgroundColor = .appColor(.neutral0)
    }
}
