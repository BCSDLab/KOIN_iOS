//
//  ShopInfoColletionView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit
import FirebaseAnalytics

final class ShopInfoCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var shops: [Shop] = []
    weak var shopDelegate: CollectionViewDelegate?
    let cellTapPublisher = PassthroughSubject<Int, Never>()
    
    
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
        register(ShopInfoCollectionViewCell.self, forCellWithReuseIdentifier: ShopInfoCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func updateShop(_ shops: [Shop]) {
        self.shops = shops
        self.reloadData()
    }
    
    private func makeAnalyticsForClickStoreList(_ storeName: String) {
        let makeEvent = MakeParamsForLog()
        let event = makeEvent.makeEventNameAction(name: .business)
        let parameters = [
            "event_label": makeEvent.makeEventTitle(title: .store_click),
            "event_category": makeEvent.makeEventCategory(category: .click),
            "value": "\(storeName)"
        ]
        Analytics.logEvent(event, parameters: parameters)
    }
}

extension ShopInfoCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shops.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopInfoCollectionViewCell.identifier, for: indexPath) as? ShopInfoCollectionViewCell else {
            return UICollectionViewCell()
        }
        let shopItem = shops[indexPath.row]
        cell.configure(info: shopItem)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.makeAnalyticsForClickStoreList(shops[indexPath.row].name)
        cellTapPublisher.send(shops[indexPath.row].id)
    }
}
