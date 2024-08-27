//
//  CategoryCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit

final class CategoryCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var shopCategories: [ShopCategory] = []
    let cellTapPublisher = PassthroughSubject<Int, Never>()
    let selectedCategoryPublisher = CurrentValueSubject<Int, Never>(0)
    private var selectedId = 0
    private var layout = UICollectionViewFlowLayout()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
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
    
    func updateCategories(_ categories: [ShopCategory]) {
         self.shopCategories = categories
         self.reloadData()
     }
    
    func updateCategory(_ id: Int) {
        selectedId = id
        for case let cell as CategoryCollectionViewCell in visibleCells {
            if let indexPath = indexPath(for: cell) {
                let category = shopCategories[indexPath.row]
                var isSelected = false
                
                if indexPath.section == 0 {
                    isSelected = category.id == id
                    cell.configure(info: shopCategories[indexPath.row], isSelected)
                }
                else {
                    isSelected = category.id + 5 == id
                    cell.configure(info: shopCategories[indexPath.row+5], isSelected)
                }

            }
        }
        selectedCategoryPublisher.send(selectedId)
    }

}

extension CategoryCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return (shopCategories.count / 5) * 5
        case 1:
            return shopCategories.count % 5
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.section == 0 {
            cell.configure(info: shopCategories[indexPath.row], false)
        }
        else if indexPath.section == 1 {
            cell.configure(info: shopCategories[indexPath.row + 5], false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedCategory = shopCategories[0]
        if indexPath.section == 0 {
            selectedCategory = shopCategories[indexPath.row]
        }
        else {
            selectedCategory = shopCategories[indexPath.row + 5]
        }
        cellTapPublisher.send(selectedCategory.id)
    }
}

extension CategoryCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = Int(UIScreen.main.bounds.width - 14 - 25 * 4) / 5
        self.layout.itemSize.width = CGFloat(size)
        return CGSize(width: size, height: Int(Float(collectionView.bounds.height - 12 ) / 2))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        layout.minimumInteritemSpacing = 8
        return CGFloat(8)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let size = CGFloat(UIScreen.main.bounds.width - 14 - 25 * 4) / 5
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        }
        else {
            let interSpacing = (UIScreen.main.bounds.width - (5 * size + 14)) / 4
            let viewSize = CGFloat(size * CGFloat(numberOfItems(inSection: 1))) + interSpacing * CGFloat((numberOfItems(inSection: 1) - 1)) + 14
            let inset = (UIScreen.main.bounds.width - viewSize) / 2 - 5
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        }
    }

}


