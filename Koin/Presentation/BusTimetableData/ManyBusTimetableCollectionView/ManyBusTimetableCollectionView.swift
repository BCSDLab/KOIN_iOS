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
    private var subscriptions = Set<AnyCancellable>()
    private var busTimeData: [RouteInfo] = []
  
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
    }
    
    func configure(busInfo: [RouteInfo]) {
        self.busTimeData = busInfo
        reloadData()
    }
}

extension ManyBusTimetableCollectionView {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return busTimeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busTimeData[section].arrivalTime.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ManyBusTimetableCollectionViewHeaderCell.reuseIdentifier, for: indexPath) as? ManyBusTimetableCollectionViewHeaderCell else { return UICollectionViewCell() }
            cell.configure(busTimeNumber: busTimeData[indexPath.section].name)
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ManyBusTimetableCollectionViewCell.identifier, for: indexPath) as? ManyBusTimetableCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(busTime: busTimeData[indexPath.section].arrivalTime[indexPath.row - 1])
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


