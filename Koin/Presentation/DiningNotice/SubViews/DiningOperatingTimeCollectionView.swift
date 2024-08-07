//
//  DiningOperatingTimeCollectionView.swift
//  koin
//
//  Created by 김나훈 on 6/8/24.
//

import UIKit

final class DiningOperatingTimeCollectionView: UICollectionView, UICollectionViewDataSource {
    
    private var timeText: [CoopOpenDTO] = []
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        dataSource = self
        delegate = self
        isScrollEnabled = false
        register(DiningOperatingTimeCollectionViewCell.self, forCellWithReuseIdentifier: DiningOperatingTimeCollectionViewCell.identifier)
        register(DiningOperatingTimeHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DiningOperatingTimeHeaderView.identifier)
        register(DiningOperatingTimeFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DiningOperatingTimeFooterView.identifier)
    }
    
    func setUpTimeText(_ timeText: [CoopOpenDTO]) {
        self.timeText = timeText
        reloadData()
    }
}
extension DiningOperatingTimeCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 30
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 34)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 1)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiningOperatingTimeHeaderView.identifier, for: indexPath) as? DiningOperatingTimeHeaderView else {
                return UICollectionReusableView()
            }
            
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiningOperatingTimeFooterView.identifier, for: indexPath) as? DiningOperatingTimeFooterView else {
                
                return UICollectionReusableView()
            }
            return footerView
        }
        return UICollectionReusableView()
    }
}

extension DiningOperatingTimeCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeText.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiningOperatingTimeCollectionViewCell.identifier, for: indexPath) as? DiningOperatingTimeCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(open: timeText[indexPath.row])
        return cell
    }
}
