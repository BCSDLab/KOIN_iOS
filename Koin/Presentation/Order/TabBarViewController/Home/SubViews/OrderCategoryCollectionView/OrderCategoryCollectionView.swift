//
//  OrderCategoryCollectionView.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import Combine
import UIKit

final class OrderCategoryCollectionView: UICollectionView,
                                         UICollectionViewDataSource,
                                         UICollectionViewDelegate {

    // MARK: Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: Data
    private var shopCategories: [ShopCategory] = []
    let selectedCategoryPublisher = CurrentValueSubject<Int, Never>(0)
    var selectedId = 1
    private var previousSelectedId = 1

    // MARK: Init
    override init(frame: CGRect, collectionViewLayout _: UICollectionViewLayout) {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.minimumInteritemSpacing = 24
        flow.minimumLineSpacing = 0
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
        reloadData()
    }
    
    func updateCategory(_ id: Int) {
        selectedId = id
        for case let cell as OrderCategoryCollectionViewCell in visibleCells {
            if let indexPath = indexPath(for: cell) {
                let category = shopCategories[indexPath.row]
                let isSelected = category.id == id
                cell.configure(info: category, isSelected)
            }
        }
        selectedCategoryPublisher.send(selectedId)
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection _: Int) -> Int {
        shopCategories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OrderCategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? OrderCategoryCollectionViewCell else { return UICollectionViewCell() }

        let info = shopCategories[indexPath.row]
        let isSelected = info.id == selectedId
        cell.configure(info: info, isSelected)
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let newlySelectedId = shopCategories[indexPath.row].id
        
        if newlySelectedId != selectedId {
            previousSelectedId = selectedId
            selectedId = newlySelectedId
            
            var indexPathsToReload: [IndexPath] = []
            if let previousIndex = shopCategories.firstIndex(where: { $0.id == previousSelectedId }) {
                indexPathsToReload.append(IndexPath(row: previousIndex, section: 0))
            }
            if let newIndex = shopCategories.firstIndex(where: { $0.id == selectedId }) {
                indexPathsToReload.append(IndexPath(row: newIndex, section: 0))
            }
            
            collectionView.reloadItems(at: indexPathsToReload)
        }
        selectedCategoryPublisher.send(selectedId)
    }
}

// MARK: - FlowLayout
extension OrderCategoryCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        CGSize(width: 48, height: 67)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout _: UICollectionViewLayout,
                        insetForSectionAt _: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}
