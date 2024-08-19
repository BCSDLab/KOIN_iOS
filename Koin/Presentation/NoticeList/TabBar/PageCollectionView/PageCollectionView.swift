//
//  PageCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Combine
import UIKit

final class PageCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    private let colors: [UIColor] = [.red, .blue, .green, .red, .blue, .green, .red, .blue, .green, .red, .blue, .green]
    let scrollBoardPublisher = PassthroughSubject<NoticeListType, Never>()
    let pageBtnPublisher = PassthroughSubject<Int, Never>()
    private var subscribtions = Set<AnyCancellable>()
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
        register(PageCollectionViewCell.self, forCellWithReuseIdentifier: PageCollectionViewCell.identifier)
        decelerationRate = .fast
        showsHorizontalScrollIndicator = false
        dataSource = self
        delegate = self
    }
}

extension PageCollectionView {
    func updateBoard(noticeList: [NoticeArticleDTO], noticeListPages: NoticeListPages, noticeListType: NoticeListType) {
        isPagingEnabled = false
        let indexPath = IndexPath(item: noticeListType.rawValue-1, section: 0)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        isPagingEnabled = true
        
        guard let cell = cellForItem(at: indexPath) as? PageCollectionViewCell else { return }
        cell.configure(noticeArticleList: noticeList, noticeListPages: noticeListPages)
    }
}

extension PageCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NoticeListType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageCollectionViewCell.identifier, for: indexPath) as? PageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.pageBtnPublisher.sink { [weak self] page in
            self?.pageBtnPublisher.send(page)
        }.store(in: &subscribtions)
        return cell
    }
}

extension PageCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.bounds.width, height: self.bounds.height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PageCollectionView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for case let cell as PageCollectionViewCell in visibleCells {
            if let indexPath = indexPath(for: cell) {
                let boardType = NoticeListType(rawValue: indexPath.row+1) ?? .전체공지
                scrollBoardPublisher.send(boardType)
                break
            }
        }
    }
}
