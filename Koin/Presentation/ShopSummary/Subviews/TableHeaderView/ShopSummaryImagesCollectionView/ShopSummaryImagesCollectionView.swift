//
//  ShopSummaryThumbnailCollectionView.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit
import Combine

final class ShopSummaryImagesCollectionView: UICollectionView {
    
    // MARK: - Properties
    private var orderImages: [OrderImage] = []
    let didScrollOutputSubject = PassthroughSubject<Int, Never>()
    let didTapThumbnailPublisher = PassthroughSubject<IndexPath, Never>()
    
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

extension ShopSummaryImagesCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(orderImages.isEmpty) { return 1 }
        return orderImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopSummaryImagesCollectionViewCell.identifier, for: indexPath) as? ShopSummaryImagesCollectionViewCell else {
            return UICollectionViewCell()
        }
        if(orderImages.isEmpty) {
            cell.configure(url: nil)
            return cell
        }
        cell.configure(url: orderImages[indexPath.row].imageUrl)
        return cell
    }

}

extension ShopSummaryImagesCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapThumbnailPublisher.send(indexPath)
    }
}

extension ShopSummaryImagesCollectionView {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = self.frame.width
        let row = Int(contentOffset.x / width + 0.5)
        guard 0 <= row else {
            return
        }
        didScrollOutputSubject.send(row)
    }
}

extension ShopSummaryImagesCollectionView {
    
    private func commonInit() {
        isPagingEnabled = true
        dataSource = self
        delegate = self
        register(ShopSummaryImagesCollectionViewCell.self, forCellWithReuseIdentifier: ShopSummaryImagesCollectionViewCell.identifier)
    }
}
