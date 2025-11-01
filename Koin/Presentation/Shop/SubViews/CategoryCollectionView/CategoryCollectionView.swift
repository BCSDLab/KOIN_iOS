//
//  CategoryCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit

final class CategoryCollectionView: UICollectionView {

    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private var shopCategories: [ShopCategory] = []
    let cellTapPublisher = PassthroughSubject<Int, Never>()
    let selectedCategoryPublisher = CurrentValueSubject<Int, Never>(0)
    private var selectedId = 0
    let publisher = PassthroughSubject<Void, Never>()

    // MARK: - Init
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let newLayout = CenterFlowLayout()
        newLayout.minimumLineSpacing = 0
        super.init(frame: frame, collectionViewLayout: newLayout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }

    // MARK: - Public
    func updateCategories(_ categories: [ShopCategory]) {
        self.shopCategories = categories
        self.reloadData()
    }

    func updateCategory(_ id: Int) {
        selectedId = id
        for case let cell as CategoryCollectionViewCell in visibleCells {
            if let indexPath = indexPath(for: cell) {
                let category = shopCategories[indexPath.row]
                let isSelected = category.id == id
                cell.configure(info: category, isSelected)
            }
        }
        selectedCategoryPublisher.send(selectedId)
    }
}

// MARK: - UICollectionViewDataSource
extension CategoryCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shopCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = shopCategories[indexPath.row]
        let isSelected = category.id == selectedId
        cell.configure(info: category, isSelected)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CategoryCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = shopCategories[indexPath.row]
        selectedId = category.id
        cellTapPublisher.send(selectedId)
        reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CategoryCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 44, height: 67)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let totalCellWidth: CGFloat = 44 * 6
        let totalPadding: CGFloat = screenWidth - 40 - totalCellWidth
        let interItemSpacing = floor(totalPadding / 5)
        return max(interItemSpacing, 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
}
