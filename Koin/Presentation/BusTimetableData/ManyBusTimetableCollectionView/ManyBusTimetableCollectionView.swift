//
//  ManyBusTimetableCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/7/24.
//

import Combine
import UIKit

// 임시 데이터 모델

final class ManyBusTimetableCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    //MARK: - Properties
    var subscriptions = Set<AnyCancellable>()
    let busTimeData: [[String]] = [["07:30", "08:00", "08:30", "09:00"], ["07:30", "08:00", "08:30", "09:00"], ["07:30", "08:00", "08:30", "09:00"], ["07:30", "08:00", "08:30", "09:00"]]
    var busTimeNumbers: [Int] = []
  
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
        register(NoticeKeywordCollectionViewCell.self, forCellWithReuseIdentifier: NoticeKeywordCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        contentInset = .zero
        register(ManyBusTimetableCollectionViewCell.self, forCellWithReuseIdentifier: ManyBusTimetableCollectionViewCell.identifier)
        register(ManyBusTimetableCollectionViewHeaderCell.self, forCellWithReuseIdentifier: ManyBusTimetableCollectionViewHeaderCell.reuseIdentifier)
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        contentInset = .zero
        
        busTimeNumbers = Array(1...busTimeData.count)
    }
    
    func configure() {
        busTimeNumbers = Array(1...busTimeData.count)
    }
}

extension ManyBusTimetableCollectionView {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return busTimeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (busTimeData.first?.count ?? 0) + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ManyBusTimetableCollectionViewHeaderCell.reuseIdentifier, for: indexPath) as? ManyBusTimetableCollectionViewHeaderCell else { return UICollectionViewCell() }
            cell.configure(busTimeNumber: busTimeNumbers[indexPath.section])
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ManyBusTimetableCollectionViewCell.identifier, for: indexPath) as? ManyBusTimetableCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(busTime: busTimeData[indexPath.section][indexPath.row - 1])
            return cell
        }
    }
  
}

extension ManyBusTimetableCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: 64, height: 52)
        } else {
            return CGSize(width: 64, height: 46)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


