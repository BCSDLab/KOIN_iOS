//
//  ReviewListCollectionView.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Combine
import UIKit

final class ReviewListCollectionView: UICollectionView, UICollectionViewDataSource {
    
    private var reviewList: [Review] = []
    private var cancellables = Set<AnyCancellable>()
    let sortTypeButtonPublisher = PassthroughSubject<ReviewSortType, Never>()
    let myReviewButtonPublisher = PassthroughSubject<Bool, Never>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(ReviewListCollectionViewCell.self, forCellWithReuseIdentifier: ReviewListCollectionViewCell.identifier)
        register(ReviewListHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ReviewListHeaderView.identifier)
        isScrollEnabled = false
        dataSource = self
        delegate = self
    }
    
    func setReviewList(_ list: [Review]) {
        reviewList = list
        reloadData()
    }
    
}

extension ReviewListCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
         return CGSize(width: collectionView.bounds.width, height: 64)
     }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReviewListHeaderView.identifier, for: indexPath) as? ReviewListHeaderView else {
                return UICollectionReusableView()
            }
            cancellables.removeAll()
            headerView.sortTypeButtonPublisher.sink { [weak self] type in
                self?.sortTypeButtonPublisher.send(type)
            }.store(in: &cancellables)
            headerView.myReviewButtonPublisher.sink { [weak self] bool in
                self?.myReviewButtonPublisher.send(bool)
            }.store(in: &cancellables)
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewListCollectionViewCell.identifier, for: indexPath) as? ReviewListCollectionViewCell else {
            return UICollectionViewCell()
        }
        let reviewItem = reviewList[indexPath.row]
        cell.configure(review: reviewItem)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let dummyCell = ReviewListCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: 150))
        dummyCell.configure(review: reviewList[indexPath.row])
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        return CGSize(width: width, height: max(estimatedSize.height, 362))
    }
    
}
