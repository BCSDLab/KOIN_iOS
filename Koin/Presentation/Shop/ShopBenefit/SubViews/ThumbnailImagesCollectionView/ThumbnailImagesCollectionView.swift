//
//  ThumbnailImagesCollectionView.swift
//  koin
//
//  Created by 홍기정 on 5/19/26.
//

import Combine
import UIKit

final class ThumbnailImagesCollectionView: UICollectionView {
    
    // MARK: - Properties
    let currentPagePublisher = PassthroughSubject<Int, Never>()
    let imageTapPublisher = PassthroughSubject<([String], IndexPath), Never>()
    
    private var thumbnailImageUrls: [String] = []
    private var currentPage = 0
    private var lastSize: CGSize = .zero
    
    // MARK: - Initializer
    init() {
        let flowLayout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
            $0.sectionInset = .zero
        }
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if frame.size != lastSize {
            lastSize = frame.size
            collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - Configure
    func configure(_ imageUrls: [String], currentPage: Int?) {
        thumbnailImageUrls = imageUrls
        reloadData()
    }
    
    func scrollTo(currentPage: Int) {
        if 0..<thumbnailImageUrls.count ~= currentPage {
            self.currentPage = currentPage
            scrollToItem(
                at: IndexPath(item: currentPage, section: 0),
                at: .centeredHorizontally,
                animated: false
            )
        }
    }
}

extension ThumbnailImagesCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnailImageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ThumbnailImagesCollectionViewCell.identifier,
            for: indexPath
        ) as? ThumbnailImagesCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(imageUrl: thumbnailImageUrls[indexPath.item])
        return cell
    }
}

extension ThumbnailImagesCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageTapPublisher.send((thumbnailImageUrls, indexPath))
        deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension ThumbnailImagesCollectionView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        sendCurrentPageIfNeeded()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        sendCurrentPageIfNeeded()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        sendCurrentPageIfNeeded()
    }
}

extension ThumbnailImagesCollectionView {
    
    private func commonInit() {
        register(ThumbnailImagesCollectionViewCell.self, forCellWithReuseIdentifier: ThumbnailImagesCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
    }
    
    private var calculatedCurrentPage: Int {
        guard bounds.width > 0, !thumbnailImageUrls.isEmpty else { return 0 }
        let page = Int(round(contentOffset.x / bounds.width))
        return min(max(page, 0), thumbnailImageUrls.count - 1)
    }
    
    private func sendCurrentPageIfNeeded() {
        let page = calculatedCurrentPage
        guard page != currentPage else { return }
        currentPage = page
        currentPagePublisher.send(page)
    }
}
