//
//  OrderShopCollectionView.swift
//  koin
//
//  Created by 이은지 on 6/30/25.
//

import UIKit

final class OrderShopCollectionView: UICollectionView, UICollectionViewDataSource {
    
    private var itemData = OrderShop.dummy()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.minimumInteritemSpacing = 12
        super.init(frame: frame, collectionViewLayout: flow)

        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        
        register(OrderShopCollectionViewCell.self,
                 forCellWithReuseIdentifier: OrderShopCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderShopCollectionViewCell.identifier, for: indexPath) as? OrderShopCollectionViewCell else { return UICollectionViewCell() }
        cell.dataBind(itemData[indexPath.item], itemRow: indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.reloadData()
    }
}

// MARK: - FlowLayout
extension OrderShopCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 128)
    }
}
