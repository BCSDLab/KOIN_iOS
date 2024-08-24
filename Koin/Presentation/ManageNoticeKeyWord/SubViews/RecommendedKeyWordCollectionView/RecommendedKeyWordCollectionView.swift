//
//  RecommendedKeyWordCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine
import UIKit

final class RecommendedKeyWordCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    private var myKeyWordList: [NoticeKeyWordDTO] = [NoticeKeyWordDTO(id: 1, keyWord: "교환학생"),
                                                     NoticeKeyWordDTO(id: 1, keyWord: "교환학생"),
                                                     NoticeKeyWordDTO(id: 1, keyWord: "교환학생"),
                                                     NoticeKeyWordDTO(id: 1, keyWord: "교환학생"),
                                                     NoticeKeyWordDTO(id: 1, keyWord: "교환학생")]
    
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
        register(RecommendedKeyWordCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedKeyWordCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        contentInset = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
    }
 
}

extension RecommendedKeyWordCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myKeyWordList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedKeyWordCollectionViewCell.identifier, for: indexPath) as? RecommendedKeyWordCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(keyWord: myKeyWordList[indexPath.item].keyWord)
        return cell
    }
}

extension RecommendedKeyWordCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = myKeyWordList[indexPath.row].keyWord
        label.font = .appFont(.pretendardMedium, size: 14)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
        return CGSize(width: size.width + 50, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

