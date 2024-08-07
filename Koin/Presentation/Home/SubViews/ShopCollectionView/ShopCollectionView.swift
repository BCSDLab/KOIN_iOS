//
//  ShopCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 1/20/24.
//

import UIKit


final class ShopCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var storeCategories: [ShopCategory] = []
    weak var storeDelegate: CollectionViewDelegate?
    
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
        register(ShopCollectionViewCell.self, forCellWithReuseIdentifier: ShopCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func updateCategories(_ categories: [ShopCategory]) {
         self.storeCategories = categories
         self.reloadData() 
     }
}

extension ShopCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storeCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopCollectionViewCell.identifier, for: indexPath) as? ShopCollectionViewCell else {
            return UICollectionViewCell()
        }
        let storeItem = storeCategories[indexPath.row]
        cell.configure(info: storeItem)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = storeCategories[indexPath.row]
        storeDelegate?.didTapCell(at: selectedCategory.id)
    }
}
