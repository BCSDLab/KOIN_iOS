//
//  OrderHistoryColletionView.swift
//  koin
//
//  Created by 김성민 on 9/8/25.
//

import UIKit
import SnapKit

final class OrderHistoryCollectionView: UICollectionView {

//    struct Item {
//        let stateText: String
//        let dateText: String
//        let image: UIImage?
//        let storeName: String
//        let menuName: String
//        let priceText: String
//        let canReorder: Bool
//    }
//
//    private var items: [Item] = []

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); commonInit() }

    private func commonInit() {
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        dataSource = self
        delegate = self

        register(OrderHistoryColletionViewCell.self,
                 forCellWithReuseIdentifier: OrderHistoryColletionViewCell.orderHistoryIdentifier)
    }

//    func update(_ items: [Item]) {
//        self.items = items
//        reloadData()
//    }
}


extension OrderHistoryCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return items.count
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderHistoryColletionViewCell.orderHistoryIdentifier, for: indexPath) as? OrderHistoryColletionViewCell else {
            return UICollectionViewCell()
        }
//        let item = items[indexPath.item]
//        cell.configure(stateText: item.stateText, dateText: item.dateText, image: item.image,
//                       storeName: item.storeName, menuName: item.menuName,
//                       priceText: item.priceText, canReorder: item.canReorder)
        return cell
    }
}

extension OrderHistoryCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }
}

extension OrderHistoryCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 286)
    }
}


