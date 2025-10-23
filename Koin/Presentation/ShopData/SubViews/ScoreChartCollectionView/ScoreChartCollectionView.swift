//
//  ScoreChartCollectionView.swift
//  koin
//
//  Created by 김나훈 on 8/11/24.
//

import UIKit

final class ScoreChartCollectionView: UICollectionView {
    
    // MARK: - Properties
    
    private var sortedStatistics: [(key: String, value: Int)] = []
    
    // MARK: - Initialize
    
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
        backgroundColor = .clear
    }
    
    func setStatistics(_ statistics: StatisticsDto) {
        sortedStatistics = statistics.ratings.sorted { $0.key > $1.key }
        reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension ScoreChartCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedStatistics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ScoreChartCollectionViewCell.identifier,
            for: indexPath
        ) as? ScoreChartCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        configureCell(cell, at: indexPath)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ScoreChartCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 19)
    }
}

extension ScoreChartCollectionView {
    private func configureCell(_ cell: ScoreChartCollectionViewCell, at indexPath: IndexPath) {
        let scoreData = sortedStatistics[indexPath.row]
        let scoreKey = scoreData.key
        let scoreValue = scoreData.value
        let totalCount = calculateTotalCount()
        
        cell.configure(score: scoreKey, count: scoreValue, totalCount: totalCount)
    }
    
    private func calculateTotalCount() -> Int {
        return sortedStatistics.reduce(0) {
            $0 + $1.value
        }
    }
}
