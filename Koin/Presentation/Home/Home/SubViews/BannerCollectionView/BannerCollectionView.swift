//
//  BannerCollectionView.swift
//  koin
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import UIKit

final class BannerCollectionView: UICollectionView, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegate {
    
    private var banners: [Banner] = []
    let tapPublisher = PassthroughSubject<Banner, Never>()
    let scrollPublisher = PassthroughSubject<(Int, Int), Never>()
    private var timer: Timer?
    private var isUserScrolling = false
    private let viewModel: HomeViewModel
    
    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: BannerCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
        isPagingEnabled = true
    }
    var showingBanner: String {
        let center = CGPoint(x: contentOffset.x + bounds.width / 2, y: bounds.height / 2)
        if let indexPath = indexPathForItem(at: center), banners.indices.contains(indexPath.item) {
            return banners[indexPath.item].title
        }
        return ""
    }
    func setBanners(_ banners: [Banner]) {
        self.banners = banners
        self.reloadData()
        startAutoScroll()
    }
}
extension BannerCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
        stopAutoScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollFinished()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollFinished()
    }
    
    private func handleScrollFinished() {
        let visibleIndex = Int(round(contentOffset.x / bounds.width))
        
        if visibleIndex == banners.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let firstIndexPath = IndexPath(item: 0, section: 0)
                self.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
                if self.isUserScrolling {
                    self.viewModel.logAnalyticsEventUseCase.logEvent(name: "CAMPUS", label: "main_next_modal", value: self.showingBanner, category: "swipe")
                }
                self.scrollPublisher.send((0, self.banners.count))
                self.isUserScrolling = false
            }
        } else {
            if isUserScrolling {
                self.viewModel.logAnalyticsEventUseCase.logEvent(name: "CAMPUS", label: "main_next_modal", value: self.showingBanner, category: "swipe")
            }
            scrollPublisher.send((visibleIndex, banners.count))
            isUserScrolling = false
        }
        
        resetAutoScrollTimer()
    }
    
    private func resetAutoScrollTimer() {
        stopAutoScroll()
        startAutoScroll()
    }
    
    func startAutoScroll() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
    }
    
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func scrollToNextItem() {
        guard !banners.isEmpty else { return }
        
        let visibleIndex = Int(round(contentOffset.x / bounds.width))
        let nextIndex = (visibleIndex + 1) % banners.count
        
        let indexPath = IndexPath(item: nextIndex, section: 0)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        scrollPublisher.send((nextIndex, banners.count))
    }
}

// MARK: - Data Source
extension BannerCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard banners.indices.contains(indexPath.item) else { return }
        tapPublisher.send(banners[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.identifier, for: indexPath) as? BannerCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(banners[indexPath.item])
        return cell
    }
}
