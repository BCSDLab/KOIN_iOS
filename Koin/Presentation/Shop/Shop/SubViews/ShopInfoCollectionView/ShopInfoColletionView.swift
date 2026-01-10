//
//  ShopInfoColletionView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit

final class ShopInfoCollectionView: UICollectionView {
    
    weak var headerView: ShopInfoHeaderView?
    weak var footerView: ShopInfoFooterView?

    // MARK: - Properties
    private var isEventShopEmpty: Bool = true
    private var headerViewHeight: CGFloat {
        switch isEventShopEmpty {
        case true: return (8+40+12+71+24+34+24)
        case false: return (8+40+12+71+24+34+24)+(100+16)
        }
    }
    private var footerViewHeight: CGFloat {
        switch shops.isEmpty {
        case true: return 250
        case false: return 0
        }
    }
    
    private var shops: [Shop] = []
    private var cancellables = Set<AnyCancellable>()
    private var headerViewSubscriptions: Set<AnyCancellable> = []
    
    // HeaderView
    let searchBarButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let sortButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let openShopToggleButtonPublisher = PassthroughSubject<Bool, Never>()
    let selectedCategoryPublisher = PassthroughSubject<Int, Never>()
    let cellTapPublisher = PassthroughSubject<(Int, String), Never>()
    let eventShopCellTapPublisher = PassthroughSubject<(Int, String), Never>()
    
    // BottomSheet Modal
    let sortOptionDidChangePublisher = PassthroughSubject<ShopSortType, Never>()
    
    // UIScrollViewDelegate
    let makeScrollLogPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Init
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    convenience init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = screenWidth - 48
        flowLayout.itemSize = CGSize(width: cellWidth, height: 128)
        flowLayout.minimumLineSpacing = 12
        self.init(frame: .zero, collectionViewLayout: flowLayout)
    }

    private func commonInit() {
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        backgroundColor = UIColor.appColor(.newBackground)
        register(ShopInfoCollectionViewCell.self, forCellWithReuseIdentifier: ShopInfoCollectionViewCell.identifier)
        register(ShopInfoHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShopInfoHeaderView.identifier)
        register(ShopInfoFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ShopInfoFooterView.identifier)
        dataSource = self
        delegate = self
    }

    // MARK: - Public
    func updateShop(_ shops: [Shop]) {
        self.shops = shops
        footerView?.updateEmptyResultView(isEmpty: shops.isEmpty)
        self.reloadData()
    }
    
    // MARK: - Update HeaderView
    func updateFilteredCategory(_ id: Int) {
        headerView?.updateFilteredCategory(id)
    }
    func putImage(data: ShopCategoryDto) {
        headerView?.putImage(data: data)
    }
    func updateEventShops(_ eventShops: [EventDto]) {
        isEventShopEmpty = eventShops.isEmpty
        headerView?.updateEventShops(eventShops)
    }
    func stopAutoScroll() {
        headerView?.stopAutoScroll()
    }
    func updateSortButtonTitle(_ newTitle: String) {
        headerView?.updateSortButtonTitle(newTitle)
    }
}

// MARK: - UICollectionViewDataSource
extension ShopInfoCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shops.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopInfoCollectionViewCell.identifier, for: indexPath) as? ShopInfoCollectionViewCell else {
            return UICollectionViewCell()
        }
        let shopItem = shops[indexPath.row]
        cell.configure(info: shopItem)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ShopInfoHeaderView.identifier, for: indexPath) as? ShopInfoHeaderView else {
                return UICollectionReusableView()
            }
            self.headerView = headerView
            bindHeaderView(headerView)
            return headerView
        case UICollectionView.elementKindSectionFooter:
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ShopInfoFooterView.identifier, for: indexPath) as? ShopInfoFooterView else {
                return UICollectionReusableView()
            }
            self.footerView = footerView
            return footerView
        default:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "view", for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: frame.width, height: headerViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: frame.width, height: footerViewHeight)
    }
    
    private func bindHeaderView(_ headerView: ShopInfoHeaderView) {
        headerViewSubscriptions.removeAll()
        
        headerView.searchBarButtonTappedPublisher.sink { [weak self] in
            self?.searchBarButtonTappedPublisher.send()
        }.store(in: &headerViewSubscriptions)
        
        headerView.sortButtonTappedPublisher.sink { [weak self] in
            self?.sortButtonTappedPublisher.send()
        }.store(in: &headerViewSubscriptions)
        
        headerView.openShopToggleButtonPublisher.sink { [weak self] isSelected in
            self?.openShopToggleButtonPublisher.send(isSelected)
        }.store(in: &headerViewSubscriptions)
        
        headerView.selectedCategoryPublisher.sink { [weak self] categoryId in
            self?.selectedCategoryPublisher.send(categoryId)
        }.store(in: &headerViewSubscriptions)
        
        headerView.eventShopCellTapPublisher.sink { [weak self] shopId, shopName in
            self?.eventShopCellTapPublisher.send((shopId, shopName))
        }.store(in: &headerViewSubscriptions)
    }
}

// MARK: - UICollectionViewDelegate
extension ShopInfoCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapPublisher.send((shops[indexPath.row].id, shops[indexPath.row].name))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ShopInfoCollectionView: UICollectionViewDelegateFlowLayout {
    // 커스텀 레이아웃 메서드 넣어도 됨
}

// MARK: - UIScrollViewDelegate
extension ShopInfoCollectionView: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            makeScrollLogPublisher.send()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        makeScrollLogPublisher.send()
    }
}
