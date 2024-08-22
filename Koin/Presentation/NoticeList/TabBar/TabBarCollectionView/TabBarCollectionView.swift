//
//  TabBarCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Combine
import SnapKit
import UIKit

final class TabBarCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    private let noticeTabList = NoticeListType.allCases
    let selectTabPublisher = PassthroughSubject<NoticeListType, Never>()
    let indicatorInfoPublisher = PassthroughSubject<(CGFloat, CGFloat), Never>()
    private let colors: [UIColor] = [.red, .blue, .green, .red, .blue, .green, .red, .blue, .green, .red, .blue, .green]
    private var isScrolled: Bool = false
    private var pendingScrollIndex: IndexPath?
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
        register(TabBarCollectionViewCell.self, forCellWithReuseIdentifier: TabBarCollectionViewCell.identifier)
        self.decelerationRate = .fast
        self.showsHorizontalScrollIndicator = false
        dataSource = self
        delegate = self
    }
}

extension TabBarCollectionView {
    func updateBoard(noticeList: [NoticeArticleDTO], noticeListType: NoticeListType) {
        isScrolled = false
        let indexPath = IndexPath(item: noticeListType.rawValue-1, section: 0)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pendingScrollIndex = indexPath
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            if !self.isScrolled {
                moveIndicator(indexPath: indexPath)
                reloadData()
            }
        }
    }
    
    private func moveIndicator(indexPath: IndexPath) {
        guard let cell = self.cellForItem(at: indexPath) as? TabBarCollectionViewCell else { return }
        
        let cellFrameInSuperview = self.convert(cell.frame, to: self.superview)
        let cellPosition = cellFrameInSuperview.minX
        let cellWidth = cellFrameInSuperview.width
        
        self.indicatorInfoPublisher.send((cellPosition, cellWidth))
    }
}

extension TabBarCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noticeTabList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabBarCollectionViewCell.identifier, for: indexPath) as? TabBarCollectionViewCell else {
            return UICollectionViewCell()
        }
       
        cell.configure(title: noticeTabList[indexPath.row].displayName)
        if indexPath == pendingScrollIndex {
            cell.selectTab(isSelected: true)
        }
        else {
            cell.selectTab(isSelected: false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabBarCollectionViewCell.identifier, for: indexPath) as? TabBarCollectionViewCell {
            cell.configure(title: noticeTabList[indexPath.row].displayName)
            selectTabPublisher.send(noticeTabList[indexPath.row])
        }
    }
}

extension TabBarCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = noticeTabList[indexPath.row].displayName
        label.font = .appFont(.pretendardMedium, size: 14)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
        return CGSize(width: size.width+24, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension TabBarCollectionView: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let indexPath = pendingScrollIndex {
            moveIndicator(indexPath: indexPath)
        }
        isScrolled = true
    }
}

