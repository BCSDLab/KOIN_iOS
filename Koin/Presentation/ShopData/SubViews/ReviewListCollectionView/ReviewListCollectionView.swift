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
    private var headerCancellables = Set<AnyCancellable>()
    private var cellCancellables = Set<AnyCancellable>()
    let sortTypeButtonPublisher = PassthroughSubject<ReviewSortType, Never>()
    let myReviewButtonPublisher = PassthroughSubject<Bool, Never>()
    let modifyButtonPublisher = PassthroughSubject<(Int, Int), Never>()
    let deleteButtonPublisher = PassthroughSubject<(Int, Int), Never>()
    let reportButtonPublisher = PassthroughSubject<(Int, Int), Never>()
    
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
            headerCancellables.removeAll()
            headerView.sortTypeButtonPublisher.sink { [weak self] type in
                self?.sortTypeButtonPublisher.send(type)
            }.store(in: &headerCancellables)
            headerView.myReviewButtonPublisher.sink { [weak self] bool in
                self?.myReviewButtonPublisher.send(bool)
            }.store(in: &headerCancellables)
            
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
        let color: UIColor = reviewList[indexPath.row].isMine ? UIColor.appColor(.primary500).withAlphaComponent(0.03) : .systemBackground
        cell.configure(review: reviewItem, backgroundColor: color)
        cell.deleteButtonPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            self.deleteButtonPublisher.send((reviewList[indexPath.row].reviewId, reviewList[indexPath.row].shopId))
        }.store(in: &cell.cancellables)
        cell.modifyButtonPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            self.modifyButtonPublisher.send((reviewList[indexPath.row].reviewId, reviewList[indexPath.row].shopId))
        }.store(in: &cell.cancellables)
        cell.reportButtonPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            self.reportButtonPublisher.send((reviewList[indexPath.row].reviewId, reviewList[indexPath.row].shopId))
        }.store(in: &cell.cancellables)
        
        return cell
    }
    
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let estimatedHeight: CGFloat = 1000
        let dummyCell = ReviewListCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
        let color: UIColor = reviewList[indexPath.row].isMine ? UIColor.appColor(.primary500).withAlphaComponent(0.03) : .systemBackground
        dummyCell.configure(review: reviewList[indexPath.row], backgroundColor: color)
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: width, height: estimatedSize.height)
    }
}
