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

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: BannerCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
        isPagingEnabled = true
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
        guard !banners.isEmpty else { return }

        let visibleIndex = Int(round(contentOffset.x / bounds.width))
        let nextIndex = (visibleIndex + 1) % banners.count

        let indexPath = IndexPath(item: nextIndex, section: 0)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        scrollPublisher.send((nextIndex, banners.count))
    }
}

extension BannerCollectionView {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleIndex = Int(round(scrollView.contentOffset.x / bounds.width))

        if visibleIndex == banners.count - 1 {
            // 마지막 배너 -> 1번으로 바로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let firstIndexPath = IndexPath(item: 0, section: 0)
                self.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
                self.scrollPublisher.send((0, self.banners.count))
            }
        } else {
            scrollPublisher.send((visibleIndex, banners.count))
        }

        resetAutoScrollTimer()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          guard banners.indices.contains(indexPath.item) else { return }
          let banner = banners[indexPath.item]
          tapPublisher.send(banner)
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
