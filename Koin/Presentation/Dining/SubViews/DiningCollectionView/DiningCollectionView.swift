//
//  DiningCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
//

import Combine
import UIKit

final class DiningCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var diningList: [DiningItem] = []
    let imageTapPublisher = PassthroughSubject<(UIImage, String), Never>()
    let shareButtonPublisher = PassthroughSubject<ShareDiningMenu, Never>()
    let likeButtonPublisher = PassthroughSubject<(Int, Bool), Never>()
    let firstCardHeightPublisher = PassthroughSubject<CGFloat, Never>()
    
    let logScrollPublisher = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var scrollDirection: ScrollLog = .scrollToDown
    
    //MARK: - UI Components
    private let diningShareToolTipImageView = CancelableImageView(frame: .zero)
    
    //MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(DiningCollectionViewCell.self, forCellWithReuseIdentifier: DiningCollectionViewCell.identifier)
        register(DiningCollectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DiningCollectionFooterView.identifier)
        dataSource = self
        delegate = self
        contentInset = .init(top: 16, left: 24, bottom: 0, right: 24)
        diningShareToolTipImageView.isHidden = true
        self.addSubview(diningShareToolTipImageView)
    }
    
    func setDiningList(_ list: [DiningItem]) {
        diningList = list
        self.reloadData()
    }
    
    func updateDiningItem(id: Int, isLiked: Bool) {
        if let index = diningList.firstIndex(where: { $0.id == id }) {
            if isLiked {
                diningList[index].increaseLike()
            } else {
                diningList[index].decreaseLike()
            }
            let indexPath = IndexPath(item: index, section: 0)
            
            if let cell = self.cellForItem(at: indexPath) as? DiningCollectionViewCell {
                cell.updateLikeButtonText(isLiked: isLiked, likeCount: diningList[indexPath.row].likes)
            }
        }
    }
    
    private func checkAndShowToolTip(heightOfDiningCard: CGFloat) {
        let hasShownImage = UserDefaults.standard.bool(forKey: "hasShownDiningShareTooltip")
        let leading = (UIScreen.main.bounds.width - 270) / 2 - 10
        diningShareToolTipImageView.snp.makeConstraints {
            $0.top.equalTo(self).offset(heightOfDiningCard - 38)
            $0.height.equalTo(100)
            $0.leading.equalTo(leading)
            $0.width.equalTo(252)
        }

        if !hasShownImage {
            diningShareToolTipImageView.isHidden = false
            diningShareToolTipImageView.setUpGif(fileName: "diningShare")
            diningShareToolTipImageView.changeXButtonSize(width: 50, height: 50)
            diningShareToolTipImageView.onXButtonTapped = { [weak self] in
                self?.diningShareToolTipImageView.isHidden = true
                UserDefaults.standard.set(true, forKey: "hasShownDiningShareTooltip")
            }
        }
    }
    
}

extension DiningCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diningList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiningCollectionFooterView.identifier, for: indexPath) as? DiningCollectionFooterView else {
                return UICollectionReusableView()
            }
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiningCollectionViewCell.identifier, for: indexPath) as? DiningCollectionViewCell else {
            return UICollectionViewCell()
        }
        let diningItem = diningList[indexPath.row]
        cell.configure(info: diningItem)
        cell.imageTapPublisher
            .sink { [weak self] tuple in
                self?.imageTapPublisher.send(tuple)
            }.store(in: &cell.cancellables)
        cell.shareButtonPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.shareButtonPublisher.send((self.diningList[indexPath.row].toShareDiningItem()))
        }.store(in: &cell.cancellables)
        cell.likeButtonPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.likeButtonPublisher.send((self.diningList[indexPath.row].id, self.diningList[indexPath.row].isLiked))
        }.store(in: &cell.cancellables)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 48
        let estimatedHeight: CGFloat = 1000
        let dummyCell = DiningCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
        dummyCell.configure(info: diningList[indexPath.row])
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        if indexPath.row == 1 {
            checkAndShowToolTip(heightOfDiningCard: estimatedSize.height)
        }
        return CGSize(width: width, height: estimatedSize.height)
    }
    
}

extension DiningCollectionView: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView.superview)
        if velocity.y > 0 {
            scrollDirection = .scrollToTop
        }
        else {
            if scrollDirection != .scrollChecked {
                scrollDirection = .scrollToDown
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let screenHeight = scrollView.frame.height
        if scrollDirection == .scrollToDown && contentOffsetY > screenHeight * 0.7 && scrollDirection != .scrollChecked {
            logScrollPublisher.send(())
            scrollDirection = .scrollChecked
        }
    }
}


