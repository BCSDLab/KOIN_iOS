//
//  EventShopCollectionView.swift
//  koin
//
//  Created by 김나훈 on 4/10/24.
//

import Combine
import UIKit

final class EventShopCollectionView: UICollectionView, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegate  {
    
    private var eventShops: [EventDTO] = []
    let cellTapPublisher = PassthroughSubject<(Int, String), Never>()
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
        register(EventShopCollectionViewCell.self, forCellWithReuseIdentifier: EventShopCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
        backgroundColor = UIColor.appColor(.newBackground)
    }
    
    func setEventShops(_ eventList: [EventDTO]) {
        self.eventShops = eventList
        self.reloadData()
    }
}

extension EventShopCollectionView {
    func startAutoScroll() {
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
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
        
        if eventShops.isEmpty { return }
        
        if currentIndex < eventShops.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        let indexPath = IndexPath(item: currentIndex, section: 0)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        scrollPublisher.send("\(currentIndex + 1)/\(eventShops.count)")
    }
    
    private func adjustCollectionViewInsets() {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let inset = (bounds.width - cellWidthIncludingSpacing) / 2
        contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

extension EventShopCollectionView {
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
        scrollPublisher.send("\(currentIndex + 1)/\(eventShops.count)")
    }
    
    private func updateCurrentIndex() {
        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let offsetX = contentOffset.x + contentInset.left
        currentIndex = Int(round(offsetX / cellWidthIncludingSpacing))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventShops.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventShopCollectionViewCell.identifier, for: indexPath) as? EventShopCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let shop = eventShops[indexPath.row]
        cell.configure(shop)
        cell.onTap = { [weak self] shopId in
            self?.cellTapPublisher.send((shopId, shop.shopName))
        }
        return cell
    }
    
}
