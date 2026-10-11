//
//  AutoScrollableInfiniteCarouselCollectionViewProtocol.swift
//  koin
//
//  Created by 홍기정 on 6/20/26.
//

import UIKit

@MainActor
protocol AutoScrollableInfiniteCarouselCollectionViewProtocol: AnyObject {
    
    func numberOfItems(in collectionView: AutoScrollableInfiniteCarouselCollectionView) -> Int
    
    func collectionView(
        _ collectionView: AutoScrollableInfiniteCarouselCollectionView,
        cellForItemAt index: Int,
        dequeueAt indexPath: IndexPath
    ) -> UICollectionViewCell
    
    func collectionView(
        _ collectionView: AutoScrollableInfiniteCarouselCollectionView,
        didSelectItemAt index: Int
    )
    
    func collectionView(
        _ collectionView: AutoScrollableInfiniteCarouselCollectionView,
        didMoveToItemAt index: Int,
        isUserInitiated: Bool
    )
}
