//
//  RecommendedSearchCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import UIKit

final class RecommendedSearchCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    private var recommendedSearchingWord: [String] = []
    let tapRecommendedWord = PassthroughSubject<String, Never>()
    
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
        register(RecommendedSearchCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedSearchCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        self.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    func updateRecommendedKeyWords(keyWords: [String]) {
        self.recommendedSearchingWord = keyWords
        reloadData()
    }
}

extension RecommendedSearchCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedSearchingWord.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedSearchCollectionViewCell.identifier, for: indexPath) as? RecommendedSearchCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(keyWord: recommendedSearchingWord[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let word = recommendedSearchingWord[indexPath.row]
        let newWord = word.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        tapRecommendedWord.send(newWord)
    }
}

extension RecommendedSearchCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = recommendedSearchingWord[indexPath.row]
        label.font = .appFont(.pretendardMedium, size: 14)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
        return CGSize(width: size.width + 32, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

