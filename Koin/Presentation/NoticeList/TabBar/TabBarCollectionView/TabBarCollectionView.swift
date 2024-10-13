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
        decelerationRate = .normal
        showsHorizontalScrollIndicator = false
        contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        dataSource = self
        delegate = self
    }
}

extension TabBarCollectionView {
    func updateBoard(noticeList: [NoticeArticleDTO], noticeListType: NoticeListType) {
        var indexPath = IndexPath(item: 0, section: 0)
        if noticeListType.rawValue < 9 {
            indexPath = IndexPath(item: noticeListType.rawValue - 4, section: 0)
        }
        else if noticeListType.rawValue > 11 {
            indexPath = IndexPath(item: noticeListType.rawValue - 7, section: 0)
        }
        else {
            indexPath = IndexPath(item: 7, section: 0)
        }
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pendingScrollIndex = indexPath
        reloadData()
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
        selectTabPublisher.send(noticeTabList[indexPath.row])
    }
}

extension TabBarCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = noticeTabList[indexPath.row].displayName
        label.font = .appFont(.pretendardMedium, size: 14)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
        return CGSize(width: size.width + 24, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
