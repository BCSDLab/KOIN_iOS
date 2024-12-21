//
//  BusAreaSelectedCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/21/24.
//

import Combine
import UIKit

final class BusAreaSelectedCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    //MARK: - Properties
    let departureBusAreaPublisher = CurrentValueSubject<BusPlace?, Never>(nil)
    let arrivalBusAreaPublisher = CurrentValueSubject<BusPlace?, Never>(nil)
    let buttonStatePublisher = PassthroughSubject<BusAreaButtonState, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var busAreaLists: [(BusPlace, Bool)] = []
    private var buttonState: BusAreaButtonState = .departureSelect
    
    //MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        dataSource = self
        delegate = self
        contentInset = .zero
        register(BusAreaSelectedCollectionViewCell.self, forCellWithReuseIdentifier: BusAreaSelectedCollectionViewCell.identifier)
        isScrollEnabled = true
        showsVerticalScrollIndicator = false
        contentInset = .zero
    }
    
    func configure(busAreaLists: [(BusPlace, Bool)], buttonState: BusAreaButtonState) {
        self.busAreaLists = busAreaLists
        self.buttonState = buttonState
        let buttonPublisher = buttonState == .departureSelect ? departureBusAreaPublisher : arrivalBusAreaPublisher
        let otherPublisher = buttonState == .departureSelect ? arrivalBusAreaPublisher : departureBusAreaPublisher
        if buttonPublisher.value == nil {
            let value: BusPlace = otherPublisher.value == .koreatech ? .station : .koreatech
            buttonPublisher.send(value)
        }
        for (index, value) in busAreaLists.enumerated() {
            if value.0 == buttonPublisher.value {
                self.busAreaLists[index].1 = true
            }
            else {
                self.busAreaLists[index].1 = false
            }
        }
        reloadData()
    }
}

extension BusAreaSelectedCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busAreaLists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusAreaSelectedCollectionViewCell.identifier, for: indexPath) as? BusAreaSelectedCollectionViewCell else {
            return UICollectionViewCell()
        }
        let item = busAreaLists[indexPath.row]
        cell.configure(busPlace: item.0.koreanDescription, isSelected: item.1)
        let disableBusPlace: BusPlace? = buttonState == .departureSelect ? arrivalBusAreaPublisher.value : departureBusAreaPublisher.value
        if let busPlace = disableBusPlace, busPlace == busAreaLists[indexPath.row].0 {
            cell.disableCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        for (index, _) in busAreaLists.enumerated() {
            busAreaLists[index].1 = (index == selectedIndex)
        }
        let publisher = buttonState == .departureSelect ? departureBusAreaPublisher : arrivalBusAreaPublisher
        publisher.send(busAreaLists[indexPath.row].0)
        reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let area: BusPlace? = buttonState == .departureSelect ? arrivalBusAreaPublisher.value : departureBusAreaPublisher.value
        let isEnabled = busAreaLists[indexPath.row].0 != area
        return isEnabled
    }
}

extension BusAreaSelectedCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = busAreaLists[indexPath.row].0.koreanDescription
        label.font = .appFont(.pretendardMedium, size: 15)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 48))
        return CGSize(width: size.width + 32, height: 48)
    }
}


