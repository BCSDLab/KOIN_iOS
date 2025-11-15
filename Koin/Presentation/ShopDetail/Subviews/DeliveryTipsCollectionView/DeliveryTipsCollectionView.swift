//
//  DeliveryTipsCollectionView.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit

final class DeliveryTipsCollectionView: UICollectionView {
    
    // MARK: - Properties
    private var deliveryTips: [DeliveryTip] = []
 
    // MARK: - Initializer
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(deliveryTips: [DeliveryTip]) {
        self.deliveryTips = deliveryTips
        reloadData()
    }
}

extension DeliveryTipsCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case 0: return CGSize(width: 200, height: 30)
        case 1:
            let remainingWidth = UIScreen.main.bounds.width - 48 - 200
            return CGSize(width: remainingWidth, height: 30)
        default: return .zero
        }
    }
}

extension DeliveryTipsCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return deliveryTips.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeliveryTipsCollectionViewCell.identifier, for: indexPath) as? DeliveryTipsCollectionViewCell else {
            return UICollectionViewCell()
        }
        switch indexPath.row {
        case 0:
            cell.configure(fromAmount: deliveryTips[indexPath.section].fromAmount, toAmount: deliveryTips[indexPath.section].toAmount)
            return cell
        case 1:
            cell.configure(fee: deliveryTips[indexPath.section].fee)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
}

extension DeliveryTipsCollectionView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        register(DeliveryTipsCollectionViewCell.self, forCellWithReuseIdentifier: DeliveryTipsCollectionViewCell.identifier)
    }
}
