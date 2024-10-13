//
//  RecommendedKeyWordCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine
import UIKit

final class RecommendedKeywordCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    //MARK: - Properties
    private var recommendedKeywordList: [String] = []
    let recommendedKeywordPublisher = PassthroughSubject<String, Never>()
    
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
        register(RecommendedKeywordCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedKeywordCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func updateRecommendedKeywords(keywords: [String]) {
        self.recommendedKeywordList = keywords
        reloadData()
    }
}

extension RecommendedKeywordCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if recommendedKeywordList.count > 5 {
            return 5
        }
        else {
            return recommendedKeywordList.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedKeywordCollectionViewCell.identifier, for: indexPath) as? RecommendedKeywordCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(keyWord: recommendedKeywordList[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        recommendedKeywordPublisher.send(recommendedKeywordList[indexPath.item])
    }
}

extension RecommendedKeywordCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = recommendedKeywordList[indexPath.row]
        label.font = .appFont(.pretendardMedium, size: 14)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
        return CGSize(width: size.width + 50, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

