//
//  NoticeKeyWordCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Combine
import UIKit

final class NoticeKeyWordCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    var noticeKeyWordList: [NoticeKeyWord] = []
    private let keyWordTapPublisher = PassthroughSubject<Int, Never>()
    
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
        register(NoticeKeyWordCollectionViewCell.self, forCellWithReuseIdentifier: NoticeKeyWordCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
}

extension NoticeKeyWordCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noticeKeyWordList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeKeyWordCollectionViewCell.identifier, for: indexPath) as? NoticeKeyWordCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.row == 0 {
            cell.configure(keyWordModel: noticeKeyWordList[indexPath.row], isSelected: true)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeKeyWordCollectionViewCell.identifier, for: indexPath) as? NoticeKeyWordCollectionViewCell {
            
            cell.configure(keyWordModel: noticeKeyWordList[indexPath.row], isSelected: true)
            keyWordTapPublisher.send(noticeKeyWordList[indexPath.row].id)
        }
    }
}

extension NoticeKeyWordCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = noticeKeyWordList[indexPath.row].keyWord
        label.font = .appFont(.pretendardBold, size: 14)
        let size = CGSize(width: label.bounds.width + 32, height: label.bounds.height + 12)
        return size
    }
}

