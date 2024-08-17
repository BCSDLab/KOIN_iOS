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
            }
        }
    }
    
    private func moveIndicator(indexPath: IndexPath ){
        guard let cell = self.cellForItem(at: indexPath) as? TabBarCollectionViewCell else { return }
        
        // 셀의 프레임을 화면 좌표계로 변환
        let cellFrameInSuperview = self.convert(cell.frame, to: self.superview)
        let cellPosition = cellFrameInSuperview.minX
        let cellWidth = cellFrameInSuperview.width
        
        // 인디케이터 정보를 ViewController로 전송
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
       
        cell.configure(title: noticeTabList[indexPath.row].displayName, isSelected: false)
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabBarCollectionViewCell.identifier, for: indexPath) as? TabBarCollectionViewCell {
            cell.configure(title: noticeTabList[indexPath.row].displayName, isSelected: true)
            selectTabPublisher.send(noticeTabList[indexPath.row])
        }
    }
}

extension TabBarCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = noticeTabList[indexPath.row].displayName
        label.font = .appFont(.pretendardMedium, size: 14)
        let size = CGSize(width: 100, height: label.bounds.height + 28)
        return size
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

