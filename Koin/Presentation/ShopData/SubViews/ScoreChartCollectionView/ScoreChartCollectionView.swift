//
//  ScoreChartCollectionView.swift
//  koin
//
//  Created by 김나훈 on 8/11/24.
//

import UIKit

final class ScoreChartCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var sortedStatistics: [(key: String, value: Int)] = []
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(ScoreChartCollectionViewCell.self, forCellWithReuseIdentifier: ScoreChartCollectionViewCell.identifier)
        isScrollEnabled = false
        dataSource = self
        delegate = self
    }
    
    func setStatistics(_ statistics: StatisticsDto) {
        self.sortedStatistics = statistics.ratings.sorted { $0.key > $1.key }
        reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedStatistics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScoreChartCollectionViewCell.identifier, for: indexPath) as? ScoreChartCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let scoreData = sortedStatistics[indexPath.row]
        let scoreKey = scoreData.key
        let scoreValue = scoreData.value
        let totalCount = sortedStatistics.reduce(0) { $0 + $1.value }
        
        cell.configure(score: scoreKey, count: scoreValue, totalCount: totalCount)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 19)
    }
}
