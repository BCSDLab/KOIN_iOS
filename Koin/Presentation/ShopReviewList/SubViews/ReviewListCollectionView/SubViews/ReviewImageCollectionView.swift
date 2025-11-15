//
//  ReviewImageCollectionView.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Combine
import UIKit

final class ReviewImageCollectionView: UICollectionView {
    
    // MARK: - Properties
    private var reviewImageList: [String] = []
    let imageTapPublisher = PassthroughSubject<([String], IndexPath), Never>()
    
    // MARK: - Initializer
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(ReviewImageCollectionViewCell.self, forCellWithReuseIdentifier: ReviewImageCollectionViewCell.identifier)
        delegate = self
        dataSource = self
        backgroundColor = .clear
    }
    
    func setReviewImageList(_ list: [String]) {
        reviewImageList = list
        reloadData()
    }
}

extension ReviewImageCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewImageCollectionViewCell.identifier, for: indexPath) as? ReviewImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let reviewImage = reviewImageList[indexPath.row]
        cell.configure(imageURL: reviewImage)
        return cell
    }
}

extension ReviewImageCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageTapPublisher.send((reviewImageList, indexPath))
        print("tapped")
    }
}
