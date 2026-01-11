//
//  ShopInfoColletionView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit

final class ShopInfoCollectionView: UICollectionView {

    // MARK: - Properties
    private var shops: [Shop] = []
    private var cancellables = Set<AnyCancellable>()
    
    let sortOptionDidChangePublisher = PassthroughSubject<ShopSortType, Never>()
    let cellTapPublisher = PassthroughSubject<(Int, String), Never>()

    // MARK: - Init
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

    // MARK: - Public
    func updateShop(_ shops: [Shop]) {
        self.shops = shops
        self.reloadData()
    }

    func calculateShopListHeight() -> CGFloat {
        let cellHeight: CGFloat = 128
        let spacing: CGFloat = 12
        let numberOfCells = CGFloat(shops.count)
        if numberOfCells == 0 { return 0 }
        return (cellHeight * numberOfCells) + (spacing * (numberOfCells - 1))
    }
}

// MARK: - UICollectionViewDataSource
extension ShopInfoCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shops.count
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
        cellTapPublisher.send((shops[indexPath.row].id, shops[indexPath.row].name))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ShopInfoCollectionView: UICollectionViewDelegateFlowLayout {
    // 커스텀 레이아웃 메서드 넣어도 됨
}
