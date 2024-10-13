//
//  MyKeyWordCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine
import UIKit

final class MyKeywordCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    
    let tapDeleteButtonPublisher = PassthroughSubject<NoticeKeywordDTO, Never>()
    let myKeywordsContentsSizePublisher = PassthroughSubject<CGFloat, Never>()
    private var myKeywordList: [NoticeKeywordDTO] = []
    
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
        register(MyKeywordCollectionViewCell.self, forCellWithReuseIdentifier: MyKeywordCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        contentInset = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
    }
    
    func updateMyKeywords(keywords: [NoticeKeywordDTO]) {
        self.myKeywordList = keywords
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myKeywordsContentsSizePublisher.send(self.contentSize.height)
    }
}

extension MyKeywordCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myKeywordList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyKeywordCollectionViewCell.identifier, for: indexPath) as? MyKeywordCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(keyWord: myKeywordList[indexPath.item].keyword)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapDeleteButtonPublisher.send(myKeywordList[indexPath.item])
    }
}

extension MyKeywordCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = myKeywordList[indexPath.row].keyword
        label.font = .appFont(.pretendardMedium, size: 14)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
        return CGSize(width: size.width + 50, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

