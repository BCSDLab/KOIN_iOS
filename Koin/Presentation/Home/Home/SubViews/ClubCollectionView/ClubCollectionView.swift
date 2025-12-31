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
    var itemWidth: CGFloat { 62 }
    var itemHeight: CGFloat { 84 }
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
    
    func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: itemWidth, height: itemHeight)
       }
       
       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return calculateSpacing()
       }
       
       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 16
       }
       
       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           insetForSectionAt section: Int) -> UIEdgeInsets {
           let spacing = calculateSpacing()
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
       }
       
       private func calculateSpacing() -> CGFloat {
           let totalCellWidth = itemWidth * 5
           let totalSpacing = self.bounds.width - totalCellWidth
           return totalSpacing / 6
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
