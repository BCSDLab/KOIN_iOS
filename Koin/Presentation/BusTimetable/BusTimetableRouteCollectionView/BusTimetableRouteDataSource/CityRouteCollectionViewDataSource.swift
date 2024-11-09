//
//  CityRouteCollectionViewDataSource.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/9/24.
//

import SnapKit
import UIKit

final class CityRouteCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var cityRouteList: [[String]] = [[]]
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if cityRouteList.count < 2 {
            return 0
        }
        else {
            if section == 0 {
                return cityRouteList[0].count
            }
            else {
                return cityRouteList[1].count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let routeItem = cityRouteList[0]
        let directionItem = cityRouteList[1]
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
            if indexPath.section == 0 {
                label.text = "노선"
            }
            else {
                label.text = "운행"
            }
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
