//
//  TimetableCollectionView.swift
//  koin
//
//  Created by 김나훈 on 11/9/24.
//

import UIKit

final class TimetableCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var somethings: [Int] = [9, 10, 11, 12, 13, 14, 15, 16]
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(TimetableCollectionViewCell.self, forCellWithReuseIdentifier: TimetableCollectionViewCell.identifier)
        register(TimetableHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TimetableHeaderView.identifier)
        dataSource = self
        delegate = self
    }
    
    func setUpSomethings() {
      
        reloadData()
    }
    
}

extension TimetableCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return somethings.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 16)
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
        cell.configure()
        return cell
    }
}
