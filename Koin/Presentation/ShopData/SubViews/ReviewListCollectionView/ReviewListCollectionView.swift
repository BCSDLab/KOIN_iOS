//
//  ReviewListCollectionView.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Combine
import UIKit

final class ReviewListCollectionView: UICollectionView {
    
    // MARK: - Properties
    
    private(set) var reviewList: [Review] = []
    private var headerCancellables = Set<AnyCancellable>()
    
    // MARK: - Publishers
    
    let sortTypeButtonPublisher = PassthroughSubject<ReviewSortType, Never>()
    let myReviewButtonPublisher = PassthroughSubject<Bool, Never>()
    let modifyButtonPublisher = PassthroughSubject<(Int, Int), Never>()
    let deleteButtonPublisher = PassthroughSubject<(Int, Int), Never>()
    let reportButtonPublisher = PassthroughSubject<(Int, Int), Never>()
    let heightChangePublisher = PassthroughSubject<Int, Never>()
    let imageTapPublisher = PassthroughSubject<UIImage?, Never>()
    
    // MARK: - Initialize
    
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
}

extension ReviewListCollectionView {
    
    func addReviewList(_ list: [Review]) {
        reviewList.append(contentsOf: list)
        reloadData()
    }
    
    func resetReviewList() {
        reviewList = []
        reloadData()
    }
    
    func setHeader(_ fetchStandard: ReviewSortType, _ isMine: Bool) {
        guard let headerView = supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? ReviewListHeaderView else {
            return
        }
        headerView.updateHeader(fetchStandard: fetchStandard, isMine: isMine)
    }
    
    func reportReview(_ reviewId: Int, shopId: Int) {
        guard let index = reviewList.firstIndex(where: {
            $0.reviewId == reviewId && $0.shopId == shopId
        }) else {
            return
        }
        
        reviewList[index].isReported = true
        let indexPath = IndexPath(item: index, section: 0)
        
        performBatchUpdates({
            reloadItems(at: [indexPath])
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.heightChangePublisher.send(self.reviewList.count)
        })
    }
    
    func disappearReview(_ reviewId: Int, shopId: Int) {
        guard let index = reviewList.firstIndex(where: {
            $0.reviewId == reviewId && $0.shopId == shopId
        }) else {
            return
        }
        
        reviewList.remove(at: index)
        let indexPath = IndexPath(item: index, section: 0)
        
        performBatchUpdates({
            deleteItems(at: [indexPath])
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.reloadData()
            self.heightChangePublisher.send(self.reviewList.count)
        })
    }
    
    func modifySuccess(_ reviewId: Int, _ reviewItem: WriteReviewRequest) {
        guard let index = reviewList.firstIndex(where: {
            $0.reviewId == reviewId
        }) else {
            return
        }
        
        reviewList[index].isModified = true
        reviewList[index].imageUrls = reviewItem.imageUrls
        reviewList[index].content = reviewItem.content
        reviewList[index].menuNames = reviewItem.menuNames
        reviewList[index].rating = reviewItem.rating
        
        let indexPath = IndexPath(item: index, section: 0)
        performBatchUpdates({
            reloadItems(at: [indexPath])
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.heightChangePublisher.send(self.reviewList.count)
        })
    }
}

// MARK: - UICollectionViewDataSource
extension ReviewListCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviewList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewListCollectionViewCell.identifier, for: indexPath) as? ReviewListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        configureCell(cell, at: indexPath)
        bindCellPublishers(cell, at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReviewListHeaderView.identifier, for: indexPath) as? ReviewListHeaderView else {
            return UICollectionReusableView()
        }
        
        bindHeaderPublishers(headerView)
        
        return headerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ReviewListCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = calculateCellHeight(for: indexPath, width: width)
        
        return CGSize(width: width, height: height)
    }
}

extension ReviewListCollectionView {
    
    private func configureCell(_ cell: ReviewListCollectionViewCell, at indexPath: IndexPath) {
        let reviewItem = reviewList[indexPath.row]
        let backgroundColor = reviewItem.isMine
            ? UIColor.appColor(.primary500).withAlphaComponent(0.03)
            : .systemBackground
        
        cell.configure(review: reviewItem, backgroundColor: backgroundColor)
    }
    
    private func bindCellPublishers(_ cell: ReviewListCollectionViewCell, at indexPath: IndexPath) {
        cell.deleteButtonPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let review = self.reviewList[indexPath.row]
                self.deleteButtonPublisher.send((review.reviewId, review.shopId))
            }
            .store(in: &cell.cancellables)
        
        cell.modifyButtonPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let review = self.reviewList[indexPath.row]
                self.modifyButtonPublisher.send((review.reviewId, review.shopId))
            }
            .store(in: &cell.cancellables)
        
        cell.reportButtonPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let review = self.reviewList[indexPath.row]
                self.reportButtonPublisher.send((review.reviewId, review.shopId))
            }
            .store(in: &cell.cancellables)
        
        cell.imageTapPublisher
            .sink { [weak self] image in
                self?.imageTapPublisher.send(image)
            }
            .store(in: &cell.cancellables)
    }
    
    private func bindHeaderPublishers(_ headerView: ReviewListHeaderView) {
        headerCancellables.removeAll()
        
        headerView.sortTypeButtonPublisher
            .sink { [weak self] type in
                self?.sortTypeButtonPublisher.send(type)
            }
            .store(in: &headerCancellables)
        
        headerView.myReviewButtonPublisher
            .sink { [weak self] bool in
                self?.myReviewButtonPublisher.send(bool)
            }
            .store(in: &headerCancellables)
    }
    
    private func calculateCellHeight(for indexPath: IndexPath, width: CGFloat) -> CGFloat {
        let estimatedHeight: CGFloat = 1000
        let dummyCell = ReviewListCollectionViewCell(
            frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight)
        )
        
        let reviewItem = reviewList[indexPath.row]
        let backgroundColor = reviewItem.isMine
            ? UIColor.appColor(.primary500).withAlphaComponent(0.03)
            : .systemBackground
        
        dummyCell.configure(review: reviewItem, backgroundColor: backgroundColor)
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        return estimatedSize.height
    }
}
