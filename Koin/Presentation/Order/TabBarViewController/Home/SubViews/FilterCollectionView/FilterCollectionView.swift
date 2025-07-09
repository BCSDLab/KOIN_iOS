//
//  FilterCollectionView.swift
//  koin
//
//  Created by 이은지 on 6/21/25.
//

import UIKit
import Combine

enum ShopFilter: String, CaseIterable {
    case IS_OPEN = "영업중"
    case DELIVERY_AVAILABLE = "배달가능"
    case TAKEOUT_AVAILABLE = "포장가능"
    case FREE_DELIVERY_TIP = "배달팁무료"

    var title: String {
        return self.rawValue
    }

    var image: UIImage? {
        let asset: ImageAsset
        switch self {
        case .IS_OPEN:
            asset = .filterIcon1
        case .DELIVERY_AVAILABLE:
            asset = .filterIcon2
        case .TAKEOUT_AVAILABLE:
            asset = .filterIcon3
        case .FREE_DELIVERY_TIP:
            asset = .filterIcon4
        }
        return UIImage.appImage(asset: asset)?.withRenderingMode(.alwaysTemplate)
    }

    var apiKey: String {
        switch self {
        case .IS_OPEN: return "IS_OPEN"
        case .DELIVERY_AVAILABLE: return "DELIVERY_AVAILABLE"
        case .TAKEOUT_AVAILABLE: return "TAKEOUT_AVAILABLE"
        case .FREE_DELIVERY_TIP: return "FREE_DELIVERY_TIP"
        }
    }

    var fetchFilterType: FetchOrderShopFilterType? {
        switch self {
        case .IS_OPEN: return .isOpen
        case .DELIVERY_AVAILABLE: return .deliveryAvailable
        case .TAKEOUT_AVAILABLE: return .takeoutAvailable
        case .FREE_DELIVERY_TIP: return .freeDeliveryTip
        }
    }
}

final class FilterCollectionView: UICollectionView {
    
    private let filters = ShopFilter.allCases
    private var selectedFilters: Set<ShopFilter> = [.IS_OPEN]
    
    let filtersDidChange = PassthroughSubject<Set<ShopFilter>, Never>()

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.minimumInteritemSpacing = 8
        super.init(frame: frame, collectionViewLayout: flow)

        backgroundColor = .clear
        showsHorizontalScrollIndicator = false

        register(FilterCollectionViewCell.self,
                 forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
        dataSource = self
        delegate   = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - DataSource
extension FilterCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifier, for: indexPath) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        let filter = filters[indexPath.item]
        let isSelected = selectedFilters.contains(filter)
        cell.configure(with: filter, isSelected: isSelected)
        return cell
    }
}

// MARK: - Delegate
extension FilterCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = filters[indexPath.item]
        
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
        
        collectionView.reloadData()
        filtersDidChange.send(selectedFilters)
    }
}

// MARK: - FlowLayout
extension FilterCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ c: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let text = filters[indexPath.item].title as NSString
        let font = UIFont.appFont(.pretendardBold, size: 14)
        let textWidth = text.size(withAttributes: [.font: font]).width
        let width = ceil(textWidth) + 39
        return CGSize(width: width, height: 34)
    }
}

// MARK: - Public Methods
extension FilterCollectionView {
    func getSelectedFilters() -> Set<ShopFilter> {
        return selectedFilters
    }
}
