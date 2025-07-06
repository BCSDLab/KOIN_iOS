//
//  OrderShopCollectionView.swift
//  koin
//
//  Created by 이은지 on 6/30/25.
//

import UIKit

final class OrderShopCollectionView: UICollectionView, UICollectionViewDataSource {
    
//    private var itemData = OrderShop.dummy()
    private var orderShop: [OrderShop] = []
    
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
    
    func updateShop(_ orderShop: [OrderShop]) {
        self.orderShop = orderShop
        self.reloadData()
    }
    
    func updateSeletecButtonColor(_ standard: FetchOrderShopListRequest) {
        guard let filterView = self.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? FilterCollectionView else {
            return
        }
        filterView.updateButtonState(standard)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("아이템 개수: ", orderShop.count)
        return orderShop.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderShopCollectionViewCell.identifier, for: indexPath) as? OrderShopCollectionViewCell else { return UICollectionViewCell() }
        cell.dataBind(orderShop[indexPath.item], itemRow: indexPath.item)
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
