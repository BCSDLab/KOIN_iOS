//
//  BannerCollectionView.swift
//  koin
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import UIKit

final class BannerCollectionView: UICollectionView, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegate  {
    
    private var banners: [Banner] = []
    let scrollPublisher = PassthroughSubject<String, Never>()
    private var timer: Timer?
    private var currentIndex = 0
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustCollectionViewInsets()
    }
    
    private func commonInit() {
        register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: BannerCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
    }
    
    func setBanners(_ banners: [Banner]) {
        
        self.banners = banners
        self.reloadData()
    }
    
}
extension BannerCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func startAutoScroll() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
    }
    
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            resetAutoScrollTimer()
        }
    }
    
    private func resetAutoScrollTimer() {
        stopAutoScroll()
        startAutoScroll()
    }
    @objc private func scrollToNextItem() {
        
        if banners.isEmpty { return }
        
        if currentIndex < banners.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        let indexPath = IndexPath(item: currentIndex, section: 0)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        scrollPublisher.send("\(currentIndex + 1)/\(banners.count)")
    }
    
    private func adjustCollectionViewInsets() {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let inset = (bounds.width - cellWidthIncludingSpacing) / 2
        contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
}
extension BannerCollectionView {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        
        let adjustedCenterX = (scrollView.bounds.width - scrollView.contentInset.left - scrollView.contentInset.right) / 2
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left + adjustedCenterX - (cellWidthIncludingSpacing / 2)) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset.x = roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left - adjustedCenterX + (cellWidthIncludingSpacing / 2)
        targetContentOffset.pointee = offset
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndex()
        resetAutoScrollTimer()
        scrollPublisher.send("\(currentIndex + 1)/\(banners.count)")
    }
    
    private func updateCurrentIndex() {
        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let offsetX = contentOffset.x + contentInset.left
        currentIndex = Int(round(offsetX / cellWidthIncludingSpacing))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.identifier, for: indexPath) as? BannerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let banner = banners[indexPath.row]
        cell.configure(banner)
        return cell
    }
    
}
