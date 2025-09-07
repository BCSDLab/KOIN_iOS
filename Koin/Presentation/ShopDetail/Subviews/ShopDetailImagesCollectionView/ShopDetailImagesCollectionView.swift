//
//  ShopDetailThumbnailCollectionView.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit
import Combine

class ShopDetailImagesCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Properties
    var urls: [String] = []
    let didScrollOutputSubject = PassthroughSubject<Int, Never>()
    
    // MARK: - Initializer
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setCollectionView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    func bind(urls: [String]){
        self.urls = urls
        self.reloadData()
    }
}

extension ShopDetailImagesCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopDetailImagesCollectionViewCell.identifier, for: indexPath) as? ShopDetailImagesCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.bind(url: urls[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = self.frame.width
        let currentPage = (contentOffset.x + width/2) / width
        didScrollOutputSubject.send(Int(currentPage))
    }
}

extension ShopDetailImagesCollectionView {
    
    private func setCollectionView() {
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        dataSource = self
        delegate = self
        register(ShopDetailImagesCollectionViewCell.self, forCellWithReuseIdentifier: ShopDetailImagesCollectionViewCell.identifier)
    }
}
