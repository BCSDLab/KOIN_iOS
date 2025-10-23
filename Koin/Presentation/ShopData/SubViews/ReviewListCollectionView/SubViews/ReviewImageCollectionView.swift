//
//  ReviewImageCollectionView.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Combine
import UIKit

final class ReviewImageCollectionView: UICollectionView, UICollectionViewDataSource {
    
    private var reviewImageList: [String] = []
    let imageTapPublisher = PassthroughSubject<UIImage?, Never>()
    
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
        dataSource = self
        backgroundColor = .clear
    }
    
    func setReviewImageList(_ list: [String]) {
        reviewImageList = list
        reloadData()
    }
}

extension ReviewImageCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewImageCollectionViewCell.identifier, for: indexPath) as? ReviewImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let reviewImage = reviewImageList[indexPath.row]
        cell.configure(imageURL: reviewImage)
        
        cell.imageTapPublisher.sink { [weak self] image in
            self?.imageTapPublisher.send(image)
        }.store(in: &cell.cancellables)
        
        return cell
    }
}
