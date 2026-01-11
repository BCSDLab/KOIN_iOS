//
//  RelatedShopCollectionView.swift
//  koin
//
//  Created by 김나훈 on 11/14/24.
//

import Combine
import UIKit

final class RelatedShopCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var cancellables = Set<AnyCancellable>()
    private var searchedShops: [Keyword] = []
    let selectedShopIdPublisher = PassthroughSubject<Int, Never>()
    
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
        delegate = self
        contentInset = .zero
        register(RelatedShopCollectionViewCell.self, forCellWithReuseIdentifier: RelatedShopCollectionViewCell.identifier)
        //        register(RelatedShopHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RelatedShopHeaderView.identifier)
        dataSource = self
    }
    
    func updateShop(keywords: [Keyword]) {
        self.searchedShops = keywords
        self.reloadData()
    }
    
}

extension RelatedShopCollectionView {
    
    //    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    //        if kind == UICollectionView.elementKindSectionHeader {
    //            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RelatedShopHeaderView.identifier, for: indexPath) as? RelatedShopHeaderView else {
    //                return UICollectionReusableView()
    //            }
    //            cancellables.removeAll()
    ////            headerView.shopSortStandardPublisher.sink { [weak self] standard in
    ////                self?.shopSortStandardPublisher.send(standard)
    ////            }.store(in: &cancellables)
    ////            headerView.shopFilterTogglePublisher.sink { [weak self] tag in
    ////                self?.shopFilterTogglePublisher.send(tag)
    ////            }.store(in: &cancellables)
    //            return headerView
    //        }
    //        return UICollectionReusableView()
    //    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedShops.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RelatedShopCollectionViewCell.identifier, for: indexPath) as? RelatedShopCollectionViewCell else {
            return UICollectionViewCell()
        }
        let shopItem = searchedShops[indexPath.row]
        cell.configure(info: shopItem)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedKeyword = searchedShops[indexPath.row]
        
        // shopIds의 첫 번째 요소 또는 shopId 중 하나를 가져옵니다.
        if let shopId = selectedKeyword.shopIds?.first ?? selectedKeyword.shopId {
            // 안전하게 shopId와 키워드를 Publisher로 보냅니다.
            selectedShopIdPublisher.send(shopId)
        } else {
            print("Error: shopId가 없습니다.")
        }
    }
}
