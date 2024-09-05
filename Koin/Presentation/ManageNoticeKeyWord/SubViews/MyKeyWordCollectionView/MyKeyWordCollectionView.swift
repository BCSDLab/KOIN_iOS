//
//  MyKeyWordCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine
import UIKit

final class MyKeyWordCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    
    let tapDeleteButtonPublisher = PassthroughSubject<NoticeKeyWordDTO, Never>()
    let myKeyWordsContentsSizePublisher = PassthroughSubject<CGFloat, Never>()
    private var myKeyWordList: [NoticeKeyWordDTO] = []
    
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
        register(MyKeyWordCollectionViewCell.self, forCellWithReuseIdentifier: MyKeyWordCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        contentInset = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
    }
    
    func updateMyKeyWords(keyWords: [NoticeKeyWordDTO]) {
        self.myKeyWordList = keyWords
        reloadData()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.myKeyWordsContentsSizePublisher.send(self.contentSize.height)
        }
    }
}

extension MyKeyWordCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myKeyWordList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyKeyWordCollectionViewCell.identifier, for: indexPath) as? MyKeyWordCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.tapDeleteButtonPublisher.sink { [weak self] myKeyWord in
            guard let self = self else {return }
            for keyWord in self.myKeyWordList {
                if myKeyWord == keyWord.keyWord {
                    self.tapDeleteButtonPublisher.send(keyWord)
                    break
                }
            }
        }.store(in: &cell.subscriptions)
        cell.configure(keyWord: myKeyWordList[indexPath.item].keyWord)
        return cell
    }
}

extension MyKeyWordCollectionView: UICollectionViewDelegateFlowLayout {
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

