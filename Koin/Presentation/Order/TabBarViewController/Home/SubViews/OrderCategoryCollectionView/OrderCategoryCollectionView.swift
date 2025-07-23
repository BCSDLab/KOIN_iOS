//
//  OrderCategoryCollectionView.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit
import Combine

final class OrderCategoryCollectionView: UICollectionView {

    // MARK: Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: Data
    private var shopCategories: [ShopCategory] = []
    let selectedCategoryPublisher = CurrentValueSubject<Int, Never>(0)
    private var selectedIndex = 0

    // MARK: Init
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

        register(OrderCategoryCollectionViewCell.self,
                 forCellWithReuseIdentifier: OrderCategoryCollectionViewCell.identifier)

        dataSource = self
        delegate = self
    }

    // MARK: - External API
    func updateCategories(_ categories: [ShopCategory]) {
        shopCategories = categories.sorted { $0.id < $1.id }
        selectedIndex = 0
        reloadData()
        if !shopCategories.isEmpty {
            selectedCategoryPublisher.send(shopCategories[selectedIndex].id)
        }
    }
    
    func updateCategory(_ id: Int) {
        guard let newIndex = shopCategories.firstIndex(where: { $0.id == id }) else { return }
        let previousIndex = selectedIndex
        selectedIndex = newIndex

        reloadItems(at: [IndexPath(row: previousIndex, section: 0), IndexPath(row: newIndex, section: 0)])
        selectedCategoryPublisher.send(shopCategories[selectedIndex].id)
    }
}

// MARK: - UICollectionViewDataSource
extension OrderCategoryCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        shopCategories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OrderCategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? OrderCategoryCollectionViewCell else { return UICollectionViewCell() }

        let info = shopCategories[indexPath.row]
        let isSelected = indexPath.row == selectedIndex
        cell.configure(info: info, isSelected)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension OrderCategoryCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != selectedIndex else { return }

        let previousIndex = selectedIndex
        selectedIndex = indexPath.row
        reloadItems(at: [IndexPath(row: previousIndex, section: 0), IndexPath(row: selectedIndex, section: 0)])

        selectedCategoryPublisher.send(shopCategories[selectedIndex].id)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
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
