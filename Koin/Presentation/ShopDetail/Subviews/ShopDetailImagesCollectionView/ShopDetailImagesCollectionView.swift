//
//  ShopDetailThumbnailCollectionView.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit
import Combine

final class ShopDetailImagesCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Properties
    private var orderImages: [OrderImage] = []
    let didScrollOutputSubject = PassthroughSubject<Int, Never>()
    
    // MARK: - Initializer
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(orderImage: [OrderImage]){
        self.orderImages = orderImage
        self.reloadData()
    }
}

extension ShopDetailImagesCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(orderImages.isEmpty) { return 1 }
        return orderImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopDetailImagesCollectionViewCell.identifier, for: indexPath) as? ShopDetailImagesCollectionViewCell else {
            return UICollectionViewCell()
        }
        if(orderImages.isEmpty) {
            cell.configure(url: nil)
            return cell
        }
        cell.configure(url: orderImages[indexPath.row].imageUrl)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension ShopDetailImagesCollectionView {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = self.frame.width
        let currentPage = contentOffset.x
        guard 0 <= currentPage else {
            return
        }
        didScrollOutputSubject.send(Int(currentPage))
    }
}

extension ShopDetailImagesCollectionView {
    
    private func commonInit() {
        isPagingEnabled = true
        dataSource = self
        delegate = self
        register(ShopDetailImagesCollectionViewCell.self, forCellWithReuseIdentifier: ShopDetailImagesCollectionViewCell.identifier)
    }
}
