//
//  LandCollectionView.swift
//  koin
//
//  Created by 김나훈 on 3/16/24.
//

import Combine
import UIKit

final class LandCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var landList = [LandItem]()
    let cellTapPublisher = PassthroughSubject<Int, Never>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(LandCollectionViewCell.self, forCellWithReuseIdentifier: LandCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func setLandList(_ list: [LandItem]) {
        landList = list
        self.reloadData()
    }
    
}

extension LandCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return landList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LandCollectionViewCell.identifier, for: indexPath) as? LandCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(info: landList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapPublisher.send(landList[indexPath.row].id)
    }
}
