//
//  CalendarCollectionView.swift
//  koin
//
//  Created by 김나훈 on 4/6/24.
//

import Combine
import UIKit

final class CalendarCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var dateList: [CalendarDate] = []
    let dateTapPublisher = PassthroughSubject<Date, Never>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: CalendarCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func generateDateList(showingDate: Date) {
        var dateList: [CalendarDate] = []
        for dayOffset in -3...3 {
            if let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) {
                dateList.append(CalendarDate(date: date, isInitDate: date.dayOfMonth() == showingDate.dayOfMonth()))
            }
        }
        self.dateList = dateList
        self.reloadData()
    }
    
}

extension CalendarCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.identifier, for: indexPath) as? CalendarCollectionViewCell else {
            return UICollectionViewCell()
        }
        let dateItem = dateList[indexPath.row]
        
        cell.configure(date: dateItem, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dateTapPublisher.send(dateList[indexPath.row].date)
        
        for row in 0..<dateList.count {
            let currentIndexPath = IndexPath(row: row, section: 0)
            if let cell = collectionView.cellForItem(at: currentIndexPath) as? CalendarCollectionViewCell {
                cell.changeSelectedCell(isSelected: indexPath == currentIndexPath, indexPath: currentIndexPath)
            }
        }
    }
}
