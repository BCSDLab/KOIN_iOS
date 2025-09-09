//
//  OrderPrepareCollectionView.swift
//  koin
//
//  Created by 김성민 on 9/9/25.
//

import UIKit

final class OrderPrepareCollectionView: UICollectionView {

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

        register(OrderPrepareCollectionViewCell.self,
                 forCellWithReuseIdentifier: OrderPrepareCollectionViewCell.OrderPrepareIdentifier)
    }


}

extension OrderPrepareCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return items.count
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderPrepareCollectionViewCell.OrderPrepareIdentifier, for: indexPath) as? OrderPrepareCollectionViewCell else {
            return UICollectionViewCell()
        }

        return cell
    }
}

extension OrderPrepareCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }
}

extension OrderPrepareCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 299)
    }
}
