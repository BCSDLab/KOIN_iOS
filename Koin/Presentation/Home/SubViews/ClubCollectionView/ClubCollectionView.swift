//
//  ClubCollectionView.swift
//  koin
//
//  Created by 김나훈 on 6/13/25.
//

import Combine
import UIKit

final class ClubCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var clubs: [ClubCategory] = []
    private var clubImages: [ImageAsset] = [ImageAsset.club1, ImageAsset.club2, ImageAsset.club3, ImageAsset.club4, ImageAsset.club5]
    let tapPublisher = PassthroughSubject<Int, Never>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        register(ClubCollectionViewCell.self, forCellWithReuseIdentifier: ClubCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func setClubs(_ clubs: [ClubCategory]) {
        self.clubs = clubs
        self.reloadData()
    }
}
extension ClubCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 62, height: 84)
       }
       
}

// MARK: - Data Source
extension ClubCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clubs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapPublisher.send(clubs[indexPath.item].id)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClubCollectionViewCell.identifier, for: indexPath) as? ClubCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(clubs[indexPath.item], image: clubImages[indexPath.row])
        return cell
    }
}
