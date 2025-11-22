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
    private var abTestResult: UserAssignType = .shareNew
    
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
        register(DiningCollectionViewCellA.self, forCellWithReuseIdentifier: DiningCollectionViewCellA.reuseIdentifier)
        register(DiningCollectionViewCellB.self, forCellWithReuseIdentifier: DiningCollectionViewCellB.reuseIdentifier)
        register(DiningCollectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DiningCollectionFooterView.identifier)
        dataSource = self
        delegate = self
        diningShareToolTipImageView.isHidden = true
        self.addSubview(diningShareToolTipImageView)
    }
    
    func setAbTestResult(result: AssignAbTestResponse) {
        if result.variableName == .shareNew {
            abTestResult = .shareNew
        }
        else if result.variableName == .shareOriginal {
            abTestResult = .shareOriginal
        }
        if abTestResult == .shareNew {
            contentInset = .init(top: 16, left: 24, bottom: 0, right: 24)
        }
        else {
            contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        }
        self.reloadData()
    }
    
    func setDiningList(_ list: [DiningItem]) {
        diningList = list
        if diningList.isEmpty {
            diningShareToolTipImageView.isHidden = true
        }
        self.reloadData()
    }
    
    private func checkAndShowToolTip(heightOfDiningCard: CGFloat) {
        let hasShownImage = UserDefaults.standard.bool(forKey: "hasShownDiningShareTooltip")
        let leading = (UIScreen.main.bounds.width - 280) / 2
        diningShareToolTipImageView.snp.updateConstraints {
            $0.top.equalTo(self).offset(heightOfDiningCard - 20)
            $0.height.equalTo(70)
            $0.leading.equalTo(self).offset(leading)
            $0.width.equalTo(252)
        }

        //if !hasShownImage {
            diningShareToolTipImageView.isHidden = false
            diningShareToolTipImageView.setUpImage(image: UIImage.appImage(asset: .diningShare) ?? UIImage())
            diningShareToolTipImageView.changeXButtonSize(width: 50, height: 50)
            diningShareToolTipImageView.onXButtonTapped = { [weak self] in
                self?.diningShareToolTipImageView.isHidden = true
                UserDefaults.standard.set(true, forKey: "hasShownDiningShareTooltip")
            }
        //}
    }
    
    func setToolTipImageViewAnimate() {
        diningShareToolTipImageView.layer.removeAllAnimations()
        diningShareToolTipImageView.transform = CGAffineTransformIdentity
        
        let transform = CGAffineTransform(translationX: 0, y: 10)
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .curveEaseInOut, .autoreverse, .allowUserInteraction]) { [weak self] in
            self?.diningShareToolTipImageView.transform = transform
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
        let diningItem = diningList[indexPath.row]
        if abTestResult == .shareNew {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiningCollectionViewCellB.reuseIdentifier, for: indexPath) as? DiningCollectionViewCellB else {
                return UICollectionViewCell()
            }
            cell.configure(info: diningItem)
            cell.imageTapPublisher
                .sink { [weak self] tuple in
                    self?.imageTapPublisher.send(tuple)
                }.store(in: &cell.cancellables)
            cell.shareButtonPublisher.sink { [weak self] in
                guard let self = self else { return }
                self.shareButtonPublisher.send((self.diningList[indexPath.row].toShareDiningItem()))
            }.store(in: &cell.cancellables)
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiningCollectionViewCellA.reuseIdentifier, for: indexPath) as? DiningCollectionViewCellA else {
                return UICollectionViewCell()
            }
            cell.configure(info: diningItem)
            cell.imageTapPublisher
                .sink { [weak self] tuple in
                    self?.imageTapPublisher.send(tuple)
                }.store(in: &cell.cancellables)
            cell.shareButtonPublisher.sink { [weak self] in
                guard let self = self else { return }
                self.shareButtonPublisher.send((self.diningList[indexPath.row].toShareDiningItem()))
            }.store(in: &cell.cancellables)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if abTestResult == .shareOriginal {
            let width = collectionView.frame.width, estimatedHeight: CGFloat = 1000
            let dummyCell = DiningCollectionViewCellA(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
            dummyCell.configure(info: diningList[indexPath.row])
            dummyCell.setNeedsLayout()
            dummyCell.layoutIfNeeded()
            let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
            let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            diningShareToolTipImageView.isHidden = true
            return CGSize(width: width, height: estimatedSize.height)
        }
        else {
            let width = collectionView.frame.width - 48, estimatedHeight: CGFloat = 1000
            let dummyCell = DiningCollectionViewCellB(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
            dummyCell.configure(info: diningList[indexPath.row])
            dummyCell.setNeedsLayout()
            dummyCell.layoutIfNeeded()
            let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
            let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            if indexPath.row == 0 {
                checkAndShowToolTip(heightOfDiningCard: estimatedSize.height)
            }
            return CGSize(width: width, height: estimatedSize.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if abTestResult == .shareOriginal {
            return 8
        }
        else {
            return 16
        }
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


