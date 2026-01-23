//
//  LostItemImagesCollectionView.swift
//  koin
//
//  Created by 홍기정 on 1/19/26.
//

import UIKit
import Combine

final class LostItemImagesCollectionView: UICollectionView {
    
    // MARK: - Properties
    private var images: [Image] = []
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
    
    func configure(images: [Image]){
        self.images = images
        self.reloadData()
    }
}

extension LostItemImagesCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(images.isEmpty) { return 1 }
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LostItemImagesCollectionViewCell.identifier, for: indexPath) as? LostItemImagesCollectionViewCell else {
            return UICollectionViewCell()
        }
        if(images.isEmpty) {
            cell.configure(url: nil)
            return cell
        }
        cell.configure(url: images[indexPath.row].imageUrl)
        return cell
    }

}

extension LostItemImagesCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapThumbnailPublisher.send(indexPath)
    }
}

extension LostItemImagesCollectionView {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = self.frame.width
        let row = Int(contentOffset.x / width + 0.5)
        guard 0 <= row else {
            return
        }
        didScrollOutputSubject.send(row)
    }
}

extension LostItemImagesCollectionView {
    
    private func commonInit() {
        isPagingEnabled = true
        dataSource = self
        delegate = self
        register(LostItemImagesCollectionViewCell.self, forCellWithReuseIdentifier: LostItemImagesCollectionViewCell.identifier)
    }
}
