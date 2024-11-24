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
    private var keywordNoticePhrase: ((String, String), Int)?
    let pageDidChangedPublisher = PassthroughSubject<Int, Never>()
    let tapNoticeListPublisher = PassthroughSubject<(Int, String), Never>()
    let moveKeywordManagePagePublisher = PassthroughSubject<Int, Never>()
    private var timer: Timer?
    private var currentIdx = 0
    private var isLastIdx: Bool = false
    private var bannerCount: Int = 0
    
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
        register(KeywordNotiCollectionViewCell.self, forCellWithReuseIdentifier: KeywordNotiCollectionViewCell.reuseIdentifier)
        dataSource = self
        delegate = self
        isPagingEnabled = true
    }
    
    func updateNoticeList(_ popularNoticeList: [NoticeArticleDTO], _ keywordNoticePhrase: ((String, String), Int)?) {
        self.popularNoticeList = popularNoticeList
        self.keywordNoticePhrase = keywordNoticePhrase
        bannerCount = keywordNoticePhrase == nil ? popularNoticeList.count : popularNoticeList.count + 1
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
        if popularNoticeList.count >= 1 {
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
            if index.row == bannerCount - 1 && scrollView.contentOffset.x > CGFloat(index.row) * scrollView.frame.width {
                
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
        if currentIdx <= bannerCount - 2 {
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
        pageDidChangedPublisher.send(nextIdx)
    }
}

extension NoticeListCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let keywordNotice = keywordNoticePhrase, indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeywordNotiCollectionViewCell.reuseIdentifier, for: indexPath) as? KeywordNotiCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(title: keywordNotice.0.0, subTitle: keywordNotice.0.1)
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeListCollectionViewCell.identifier, for: indexPath) as? NoticeListCollectionViewCell else {
                return UICollectionViewCell()
            }
            let newIndex = bannerCount == 5 ? indexPath.row - 1 : indexPath.row
            let noticeArticleTitle = popularNoticeList[newIndex]
            cell.configure(title: noticeArticleTitle.title)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let keywordNoticePhrase = keywordNoticePhrase, indexPath.row == 0 {
            moveKeywordManagePagePublisher.send(keywordNoticePhrase.1)
        }
        else {
            tapNoticeListPublisher.send((popularNoticeList[indexPath.row].id, popularNoticeList[indexPath.row].title))
        }
    }
}
