//
//  AutoScrollableInfiniteCarouselCollectionView.swift
//  koin
//
//  Created by 홍기정 on 6/20/26.
//

import UIKit

class AutoScrollableInfiniteCarouselCollectionView: UICollectionView {
    
    // MARK: - Properties
    weak var carouselDelegate: (any AutoScrollableInfiniteCarouselCollectionViewProtocol)?
    
    var autoScrollInterval: TimeInterval? {
        didSet { resetAutoScrollTimer() }
    }
    
    var currentItemIndex: Int? {
        guard realItemCount > 0 else { return nil }
        return logicalIndex(for: currentPhysicalIndex)
    }
    
    private var timer: Timer?
    private var needsInitialPosition = false
    private var isUserScrolling = false
    
    private var realItemCount: Int {
        max(carouselDelegate?.numberOfItems(in: self) ?? 0, 0)
    }
    
    private var displayedItemCount: Int {
        realItemCount > 1 ? realItemCount + 2 : realItemCount
    }
    
    private var currentPhysicalIndex: Int {
        guard bounds.width > 0 else { return initialPhysicalIndex }
        let index = Int(round(contentOffset.x / bounds.width))
        return min(max(index, 0), max(displayedItemCount - 1, 0))
    }
    
    private var initialPhysicalIndex: Int {
        realItemCount > 1 ? 1 : 0
    }
    
    // MARK: - Initializer
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configureCollectionView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Life Cycle
    override func didMoveToWindow() {
        super.didMoveToWindow()
        window == nil ? stopAutoScroll() : startAutoScroll()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard needsInitialPosition, bounds.width > 0 else { return }
        moveToPhysicalIndex(initialPhysicalIndex, animated: false)
        needsInitialPosition = false
    }
    
    // MARK: - Methods
    func reloadCarouselData() {
        stopAutoScroll()
        reloadData()
        needsInitialPosition = true
        setNeedsLayout()
        startAutoScroll()
    }
}

extension AutoScrollableInfiniteCarouselCollectionView {

    private func startAutoScroll() {
        guard let autoScrollInterval,
              timer == nil,
              window != nil,
              realItemCount > 1,
              autoScrollInterval > 0,
              !isDragging,
              !isDecelerating else { return }

        let timer = Timer(timeInterval: autoScrollInterval, repeats: true) { [weak self] _ in
            self?.scrollToNextItem()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    private func configureCollectionView() {
        dataSource = self
        delegate = self
        isPagingEnabled = true
        decelerationRate = .fast
        showsHorizontalScrollIndicator = false

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
        }
    }

    private func logicalIndex(for physicalIndex: Int) -> Int {
        guard realItemCount > 1 else { return 0 }

        switch physicalIndex {
        case 0:
            return realItemCount - 1
        case realItemCount + 1:
            return 0
        default:
            return physicalIndex - 1
        }
    }

    private func moveToPhysicalIndex(_ index: Int, animated: Bool) {
        guard displayedItemCount > index else { return }
        scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: animated
        )
    }

    private func correctPositionIfNeeded(at physicalIndex: Int) {
        guard realItemCount > 1 else { return }

        if physicalIndex == 0 {
            moveToPhysicalIndex(realItemCount, animated: false)
        } else if physicalIndex == realItemCount + 1 {
            moveToPhysicalIndex(1, animated: false)
        }
    }

    private func resetAutoScrollTimer() {
        stopAutoScroll()
        startAutoScroll()
    }

    private func scrollToNextItem() {
        guard realItemCount > 1 else { return }
        moveToPhysicalIndex(currentPhysicalIndex + 1, animated: true)
    }

    private func handleScrollFinished() {
        guard realItemCount > 0 else { return }

        let physicalIndex = currentPhysicalIndex
        let logicalIndex = logicalIndex(for: physicalIndex)
        correctPositionIfNeeded(at: physicalIndex)
        carouselDelegate?.collectionView(
            self,
            didMoveToItemAt: logicalIndex,
            isUserInitiated: isUserScrolling
        )
        isUserScrolling = false
        resetAutoScrollTimer()
    }
}

extension AutoScrollableInfiniteCarouselCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedItemCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let carouselDelegate else { return UICollectionViewCell() }
        return carouselDelegate.collectionView(
            self,
            cellForItemAt: logicalIndex(for: indexPath.item),
            dequeueAt: indexPath
        )
    }
}

extension AutoScrollableInfiniteCarouselCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard realItemCount > 0 else { return }
        carouselDelegate?.collectionView(self, didSelectItemAt: logicalIndex(for: indexPath.item))
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
        stopAutoScroll()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { handleScrollFinished() }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollFinished()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleScrollFinished()
    }
}
