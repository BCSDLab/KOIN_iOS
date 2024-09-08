//
//  NoticeListCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/30/24.
//

import Combine
import UIKit

final class NoticeListCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var popularNoticeList: [NoticeArticleDTO] = []
    let pageDidChangedPublisher = PassthroughSubject<Int, Never>()
    let tapNoticeListPublisher = PassthroughSubject<Int, Never>()
    private var timer: Timer?
    private var currentIdx = 0
    private var isLastIdx: Bool = false
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        register(NoticeListCollectionViewCell.self, forCellWithReuseIdentifier: NoticeListCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        isPagingEnabled = true
    }
    
    func updateNoticeList(_ popularNoticeList: [NoticeArticleDTO]) {
        self.popularNoticeList = popularNoticeList
        startAutoScroll()
        reloadData()
    }
    
    func pageControlChanged(_ index: Int) {
        isPagingEnabled = false
        let finalIndex = IndexPath(row: index, section: 0)
        currentIdx = index
        scrollToItem(at: finalIndex, at: .centeredHorizontally, animated: true)
        isPagingEnabled = true
    }
    
    private func startAutoScroll() {
        if popularNoticeList.count >= 4 {
            timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resetAutoScrollTimer()
        if let index = indexPathForItem(at: CGPoint(x: scrollView.contentOffset.x, y: scrollView.frame.height)) {
            if !isLastIdx {
                currentIdx = index.row
                pageDidChangedPublisher.send(index.row)
            }
            isLastIdx = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            resetAutoScrollTimer()
        }
        if let index = indexPathForItem(at: CGPoint(x: scrollView.contentOffset.x, y: scrollView.frame.height)) {
            if index.row == 3 && scrollView.contentOffset.x > CGFloat(index.row) * scrollView.frame.width {
                
                isPagingEnabled = false
                scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
                isPagingEnabled = true
                currentIdx = 0
                isLastIdx = true
                pageDidChangedPublisher.send(0)
            }
            else {
                isLastIdx = false
            }
        }
    }
    
    private func resetAutoScrollTimer() {
        stopAutoScroll()
        startAutoScroll()
    }
    
    @objc private func scrollToNextItem() {
        var nextIdx = 0
        if currentIdx <= 2 {
            currentIdx += 1
            nextIdx = currentIdx
        }
        else {
            currentIdx = 0
            nextIdx = 0
        }
        isPagingEnabled = false
        scrollToItem(at: IndexPath(row: nextIdx, section: 0), at: .centeredHorizontally, animated: true)
        isPagingEnabled = true
        pageDidChangedPublisher.send(currentIdx)
    }
}

extension NoticeListCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if popularNoticeList.count > 4 {
            return 4
        }
        else {
            return popularNoticeList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeListCollectionViewCell.identifier, for: indexPath) as? NoticeListCollectionViewCell else {
            return UICollectionViewCell()
        }
        let noticeArticleTitle = popularNoticeList[indexPath.row]
        cell.configure(title: noticeArticleTitle.title)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapNoticeListPublisher.send(popularNoticeList[indexPath.row].id)
    }
}
