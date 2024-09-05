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
    private var recommendedKeyWordList: [String] = []
    let recommendedKeyWordPublisher = PassthroughSubject<String, Never>()
    
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
    }
    
    func updateRecommendedKeyWords(keyWords: [String]) {
        self.recommendedKeyWordList = keyWords
        reloadData()
    }
}

extension RecommendedKeyWordCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if recommendedKeyWordList.count > 5 {
            return 5
        }
        else {
            return recommendedKeyWordList.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedKeyWordCollectionViewCell.identifier, for: indexPath) as? RecommendedKeyWordCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.recommendedKeyWordPublisher.sink { [weak self] in
            guard let self = self else { return }
            let keyWord = self.recommendedKeyWordList[indexPath.row]
            self.recommendedKeyWordPublisher.send(keyWord)
        }.store(in: &cell.subscriptions)
        cell.configure(keyWord: recommendedKeyWordList[indexPath.item])
        return cell
    }
}

extension RecommendedKeyWordCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = recommendedKeyWordList[indexPath.row]
        label.font = .appFont(.pretendardMedium, size: 14)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
        return CGSize(width: size.width + 50, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

