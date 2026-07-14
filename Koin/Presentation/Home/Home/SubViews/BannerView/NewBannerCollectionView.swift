//
//  NewBannerCollectionView.swift
//  koin
//
//  Created by 홍기정 on 6/20/26.
//

import UIKit

final class NewBannerCollectionView: AutoScrollableInfiniteCarouselCollectionView {

    // MARK: - Properties
    private var banners: [Banner] = []
    private let onBannerTap: (Banner) -> Void
    private let onPageChanged: (Int, Int) -> Void
    private let onBannerSwiped: (Banner) -> Void

    var currentTitle: String? {
        if let currentItemIndex, banners.indices.contains(currentItemIndex) {
            return banners[currentItemIndex].title
        } else {
            return nil
        }
    }

    // MARK: - Initialization
    init(
        onBannerTap: @escaping (Banner) -> Void,
        onPageChanged: @escaping (Int, Int) -> Void,
        onBannerSwiped: @escaping (Banner) -> Void,
    ) {
        self.onBannerTap = onBannerTap
        self.onPageChanged = onPageChanged
        self.onBannerSwiped = onBannerSwiped
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.autoScrollInterval = 3
        
        carouselDelegate = self
        register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: BannerCollectionViewCell.identifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    func setBanners(_ banners: [Banner]) {
        self.banners = banners
        reloadCarouselData()
        onPageChanged(0, banners.count)
    }
}

// MARK: - AutoScrollableInfiniteCarouselCollectionViewProtocol

extension NewBannerCollectionView: AutoScrollableInfiniteCarouselCollectionViewProtocol {
    
    func numberOfItems(in collectionView: AutoScrollableInfiniteCarouselCollectionView) -> Int {
        banners.count
    }

    func collectionView(
        _ collectionView: AutoScrollableInfiniteCarouselCollectionView,
        cellForItemAt index: Int,
        dequeueAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.identifier, for: indexPath) as? BannerCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(banners[index])
        return cell
    }

    func collectionView(
        _ collectionView: AutoScrollableInfiniteCarouselCollectionView,
        didSelectItemAt index: Int
    ) {
        onBannerTap(banners[index])
    }

    func collectionView(
        _ collectionView: AutoScrollableInfiniteCarouselCollectionView,
        didMoveToItemAt index: Int,
        isUserInitiated: Bool
    ) {
        onPageChanged(index, banners.count)
        if isUserInitiated {
            onBannerSwiped(banners[index])
        }
    }
}
