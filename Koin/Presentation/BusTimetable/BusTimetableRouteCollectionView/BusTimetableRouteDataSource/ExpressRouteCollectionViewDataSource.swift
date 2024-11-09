//
//  ExpressRouteCollectionViewDataSource.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/9/24.
//

import UIKit

final class ExpressRouteCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var expressRouteList: [String] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return expressRouteList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = expressRouteList.count
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusTimetableRouteCollectionViewCell.identifier, for: indexPath) as? BusTimetableRouteCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = UICollectionReusableView()
            let label = UILabel()
            label.font = .appFont(.pretendardRegular, size: 16)
            label.textColor = .appColor(.neutral600)
            label.text = "운행"
            label.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(label)
            label.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(24)
            }
            
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
}
