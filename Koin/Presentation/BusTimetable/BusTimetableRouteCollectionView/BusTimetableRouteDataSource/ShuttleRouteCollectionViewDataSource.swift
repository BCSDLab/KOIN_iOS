//
//  ShuttleRouteCollectionViewDataSource.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/9/24.
//

import UIKit

final class ShuttleRouteCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var shuttleRouteList: [String] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shuttleRouteList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = shuttleRouteList[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusTimetableRouteCollectionViewCell.identifier, for: indexPath) as? BusTimetableRouteCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
}
