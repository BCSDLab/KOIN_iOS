//
//  TimetableCollectionView.swift
//  koin
//
//  Created by 김나훈 on 11/9/24.
//

import Combine
import UIKit

enum TimetableGridMetrics {
    static let dayCount = 5
    static let timeColumnWidth: CGFloat = 17
    static let headerHeight: CGFloat = 16
    static let hourHeight: CGFloat = 70
    static let slotHeight = hourHeight / 2
    static let lineWidth: CGFloat = 1
    static let cornerRadius: CGFloat = 10

    static func linePath(in bounds: CGRect, includesHalfHour: Bool) -> CGPath {
        let path = UIBezierPath()
        let dayWidth = max(0, bounds.width - timeColumnWidth) / CGFloat(dayCount)
        for day in 0..<dayCount {
            let x = timeColumnWidth + CGFloat(day) * dayWidth - lineWidth / 2
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        path.move(to: CGPoint(x: 0, y: bounds.height - lineWidth / 2))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - lineWidth / 2))
        if includesHalfHour {
            path.move(to: CGPoint(x: timeColumnWidth, y: slotHeight - lineWidth / 2))
            path.addLine(to: CGPoint(x: bounds.width, y: slotHeight - lineWidth / 2))
        }
        return path.cgPath
    }
}

final class TimetableCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    let heightChangedPublisher = PassthroughSubject<Void, Never>()
    
    private var timeTexts: [Int] = [] {
        didSet {
            reloadData()
            
            heightChangedPublisher.send()
        }
    }

    var requiredHeight: CGFloat {
        TimetableGridMetrics.headerHeight + CGFloat(timeTexts.count) * TimetableGridMetrics.hourHeight
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        configureView()
        dataSource = self
        delegate = self
        timeTexts = Array(9...17)
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        isScrollEnabled = false
    }

    private func setUpLayouts() {
        register(TimetableCollectionViewCell.self, forCellWithReuseIdentifier: TimetableCollectionViewCell.identifier)
        register(TimetableHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TimetableHeaderView.identifier)
    }
    
    func updateLecture(lectureTime: [Int]) {
        guard timeTexts != lectureTime else { return }
        self.timeTexts = lectureTime
    }
    
}

extension TimetableCollectionView {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: TimetableGridMetrics.hourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeTexts.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: TimetableGridMetrics.headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TimetableHeaderView.identifier, for: indexPath) as? TimetableHeaderView else {
                return UICollectionReusableView()
            }
            return headerView
        }
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimetableCollectionViewCell.identifier, for: indexPath) as? TimetableCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: String(timeTexts[indexPath.row]))
        
        
        return cell
    }
}
