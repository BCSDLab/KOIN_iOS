//
//  OrderCategoryCollectionView.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit
import Combine

final class OrderCategoryCollectionView: UICollectionView {

    // MARK: - Combine & Data
    private var subscriptions = Set<AnyCancellable>()
    private var shopCategories: [ShopCategory] = []
    let selectedCategoryPublisher = PassthroughSubject<Int, Never>()
    private var selectedId = 1

    // MARK: - Init
    override init(frame: CGRect, collectionViewLayout _: UICollectionViewLayout) {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.minimumInteritemSpacing = 48
        super.init(frame: frame, collectionViewLayout: flow)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        contentInset = .zero
        backgroundColor = .clear

        register(OrderCategoryCollectionViewCell.self, forCellWithReuseIdentifier: OrderCategoryCollectionViewCell.identifier)

        dataSource = self
        delegate = self
    }

    // MARK: - API
    func updateCategories(_ categories: [ShopCategory]) {
        self.shopCategories = categories.filter { $0.id != -1 }
        self.reloadData()
    }

    func updateCategory(_ id: Int) {
        selectedId = id
        for index in 0..<shopCategories.count {
            if shopCategories[index].id == selectedId {
                let selectedIndexPath = IndexPath(row: index, section: 0)
                scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
        reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension OrderCategoryCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shopCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCategoryCollectionViewCell.identifier, for: indexPath) as? OrderCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = shopCategories[indexPath.row]
        let isSelected = category.id == selectedId
        cell.configure(info: category, isSelected)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension OrderCategoryCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = shopCategories[indexPath.row]
        selectedCategoryPublisher.send(category.id)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout\
extension OrderCategoryCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 48, height: 67)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
}
