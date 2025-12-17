//
//  MenuListCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
//

import Combine
import UIKit

final class MenuListCollectionView: UICollectionView, UICollectionViewDataSource {
    
    var imageTapPublisher = PassthroughSubject<UIImage?, Never>()
    private var menuCategories: [MenuCategory] = []
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        dataSource = self
        delegate = self
        register(MenuListCollectionViewCell.self, forCellWithReuseIdentifier: MenuListCollectionViewCell.identifier)
        register(MenuSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MenuSectionHeaderView.identifier)
        register(MenuSectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: MenuSectionFooterView.identifier)
    }
    
    func setMenuCategories(_ categories: [MenuCategory]) {
        self.menuCategories = categories
        reloadData()
    }

    
    func scroll(_ indexPath: IndexPath) {
        scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
}
extension MenuListCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MenuSectionHeaderView.identifier, for: indexPath) as? MenuSectionHeaderView else {
                return UICollectionReusableView()
            }
            headerView.setText(text: menuCategories[indexPath.section].name)
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MenuSectionFooterView.identifier, for: indexPath) as? MenuSectionFooterView else {
                return UICollectionReusableView()
            }
            return footerView
        }
        return UICollectionReusableView()
    }
    
    
}

extension MenuListCollectionView {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return menuCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let menuCategory = menuCategories[section]
        var itemCount = 0
        for menu in menuCategory.menus ?? [] {
            if let optionPrices = menu.optionPrices, !optionPrices.isEmpty {
                itemCount += optionPrices.count
            } else {
                itemCount += 1
            }
        }
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuListCollectionViewCell.identifier, for: indexPath) as? MenuListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.onTap = { [weak self] image in
            self?.imageTapPublisher.send(image)
        }
        let menuCategory = menuCategories[indexPath.section]
        var totalPreviousOptions = 0
        
        for menu in menuCategory.menus ?? [] {
            let currentMenuOptionCount = menu.optionPrices?.count ?? 1
            
            if indexPath.row < totalPreviousOptions + currentMenuOptionCount {
                let menuOptionIndex = indexPath.row - totalPreviousOptions
                let optionPrice = menu.optionPrices?[menuOptionIndex]
                
                let nameWithOption = optionPrice != nil ? "\(menu.name ?? "-") - \(optionPrice!.option)" : menu.name
                let price = optionPrice?.price ?? menu.singlePrice ?? 0
                
                cell.configure(menuName: nameWithOption ?? "", price: price, imageUrls: menu.imageUrls)
                return cell
            }
            
            totalPreviousOptions += currentMenuOptionCount
        }
        
        cell.configure(menuName: "알 수 없는 메뉴", price: 0, imageUrls: nil)
        return cell
    }
}
