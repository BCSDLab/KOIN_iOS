//
//  ShopInfoColletionView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit
import FirebaseAnalytics

final class ShopInfoCollectionView: UICollectionView {
    
    private var shops: [Shop] = []
    weak var shopDelegate: CollectionViewDelegate?
    private var cancellables = Set<AnyCancellable>()
    let shopSortStandardPublisher = PassthroughSubject<Any, Never>()
    let cellTapPublisher = PassthroughSubject<(Int, String), Never>()
    let shopFilterTogglePublisher = PassthroughSubject<Int, Never>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    convenience init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = screenWidth - 48
        flowLayout.itemSize = CGSize(width: cellWidth, height: 128)
        flowLayout.minimumLineSpacing = 12
        self.init(frame: .zero, collectionViewLayout: flowLayout)
        self.isScrollEnabled = false
    }
    
    private func commonInit() {
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        backgroundColor = UIColor.appColor(.newBackground)
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

// MARK: - UICollectionViewDataSource
extension ShopInfoCollectionView: UICollectionViewDataSource {
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
}

// MARK: - UICollectionViewDelegate
extension ShopInfoCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.makeAnalyticsForClickStoreList(shops[indexPath.row].name)
        cellTapPublisher.send((shops[indexPath.row].id, shops[indexPath.row].name))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ShopInfoCollectionView: UICollectionViewDelegateFlowLayout {
}
