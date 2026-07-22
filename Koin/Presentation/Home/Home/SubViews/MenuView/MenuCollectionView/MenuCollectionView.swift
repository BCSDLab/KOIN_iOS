//
//  MenuCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 1/20/24.
//

import UIKit

final class MenuCollectionView: UICollectionView, UICollectionViewDataSource {
    
    private var menuItems: [String] = []
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: MenuCollectionViewCell.identifier)
        dataSource = self
    }
    
    func updateDining(_ diningList : [String]) {
        menuItems = diningList
        reloadData()
    }
}

extension MenuCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.identifier, for: indexPath) as? MenuCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(labelText: menuItems[indexPath.row])
        return cell
    }
}

