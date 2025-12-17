//
//  OrderShopCollectionView.swift
//  koin
//
//  Created by 이은지 on 6/30/25.
//

import UIKit

final class OrderShopCollectionView: UICollectionView {
    
    private var orderShop: [OrderShop] = []
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(OrderShopCollectionViewCell.self, forCellWithReuseIdentifier: OrderShopCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func updateShop(_ orderShop: [OrderShop], completion: (() -> Void)? = nil) {
        self.orderShop = orderShop
        self.reloadData()

        DispatchQueue.main.async {
            completion?()
        }
    }

    func calculateCollectionViewHeight() -> CGFloat {
        let itemHeight: CGFloat = 128
        let spacing: CGFloat = 12
        let numberOfItems = CGFloat(orderShop.count)
        
        if numberOfItems == 0 {
            return 0
        }
        
        return (itemHeight * numberOfItems) + (spacing * (numberOfItems - 1))
    }
}

// MARK: - UICollectionViewDataSource
extension OrderShopCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderShop.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderShopCollectionViewCell.identifier, for: indexPath) as? OrderShopCollectionViewCell else { return UICollectionViewCell() }
        cell.dataBind(orderShop[indexPath.item], itemRow: indexPath.item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension OrderShopCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.reloadData()
    }
}
