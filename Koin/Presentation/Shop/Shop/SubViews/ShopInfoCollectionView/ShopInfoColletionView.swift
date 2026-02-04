//
//  ShopInfoColletionView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit

final class ShopInfoCollectionView: UICollectionView {
    
    private var headerView: ShopInfoHeaderView? {
        let indexPath = IndexPath(item: 0, section: 0)
        return supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? ShopInfoHeaderView
    }
    
    // MARK: - HeaderViewState
    private var selectedCategoryId: Int = 1
    private var categoryData: ShopCategoryDto = ShopCategoryDto(totalCount: 0, shopCategories: [])
    private var eventShops: [EventDto] = []
    private var sortButtonTitle: String = "기본순"
    private var isOpenShopToggleButtonSelected: Bool = false
    
    // MARK: - Properties
    private var shops: [Shop] = [] {
        didSet { shouldShowEmptyView = shops.isEmpty }
    }
    private var shouldShowEmptyView: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private var headerViewSubscription = Set<AnyCancellable>()
    
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
        self.reloadData()
    }
    
    // MARK: - Update HeaderView
    func updateFilteredCategory(_ id: Int) {
        self.selectedCategoryId = id
        headerView?.updateFilteredCategory(id)
    }
    func putImage(data: ShopCategoryDto) {
        self.categoryData = data
        headerView?.putImage(data: data)
    }
    func updateEventShops(_ eventShops: [EventDto]) {
//        self.eventShops = eventShops
//        headerView?.updateEventShops(eventShops)
    }
    func stopAutoScroll() {
        headerView?.stopAutoScroll()
    }
    func updateSortButtonTitle(_ newTitle: String) {
        self.sortButtonTitle = newTitle
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
            updateHeaderView(headerView)
            bindHeaderView(headerView)
            return headerView
        case UICollectionView.elementKindSectionFooter:
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ShopInfoFooterView.identifier, for: indexPath) as? ShopInfoFooterView else {
                return UICollectionReusableView()
            }
            footerView.updateEmptyResultView(isEmpty: shops.isEmpty)
            return footerView
        default:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "view", for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let baseHeight: CGFloat = 8+40+12+71+24+34+24
        let eventShopHeight: CGFloat = 100+16
        let headerViewHeight: CGFloat = eventShops.isEmpty ? baseHeight : baseHeight+eventShopHeight
        return CGSize(width: frame.width, height: headerViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let footerViewHeight: CGFloat = shouldShowEmptyView ? 250 : .zero
        return CGSize(width: frame.width, height: footerViewHeight)
    }
    
    private func updateHeaderView(_ headerView: ShopInfoHeaderView) {
        headerView.updateFilteredCategory(selectedCategoryId)
        headerView.putImage(data: categoryData)
        headerView.updateEventShops(eventShops)
        headerView.updateSortButtonTitle(sortButtonTitle)
        headerView.updateOpenShopToggleButton(isOpenShopToggleButtonSelected)
    }
    
    private func bindHeaderView(_ headerView: ShopInfoHeaderView) {
        headerViewSubscription.removeAll()

        headerView.searchBarButtonTappedPublisher.sink { [weak self] in
            self?.searchBarButtonTappedPublisher.send()
        }.store(in: &headerViewSubscription)
        
        headerView.sortButtonTappedPublisher.sink { [weak self] in
            self?.sortButtonTappedPublisher.send()
        }.store(in: &headerViewSubscription)
        
        headerView.openShopToggleButtonPublisher.sink { [weak self] isSelected in
            self?.isOpenShopToggleButtonSelected = isSelected
            self?.openShopToggleButtonPublisher.send(isSelected)
        }.store(in: &headerViewSubscription)
        
        headerView.selectedCategoryPublisher.sink { [weak self] categoryId in
            self?.selectedCategoryPublisher.send(categoryId)
        }.store(in: &headerViewSubscription)
        
        headerView.eventShopCellTapPublisher.sink { [weak self] shopId, shopName in
            self?.eventShopCellTapPublisher.send((shopId, shopName))
        }.store(in: &headerViewSubscription)
    }
}

// MARK: - UICollectionViewDelegate
extension ShopInfoCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTapPublisher.send((shops[indexPath.row].id, shops[indexPath.row].name))
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader {
            headerView?.stopAutoScroll()
        }
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
