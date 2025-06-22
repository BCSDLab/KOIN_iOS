//
//  FilterCollectionView.swift
//  koin
//
//  Created by 이은지 on 6/21/25.
//

import UIKit

final class FilterCollectionView: UICollectionView, UICollectionViewDataSource {
    
    private var itemData = OrderFilterData.dummy()
    private var selectedIndex = 0
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifier, for: indexPath) as? FilterCollectionViewCell else { return UICollectionViewCell() }
        cell.dataBind(itemData[indexPath.item], itemRow: indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
    }
}

// MARK: - FlowLayout
extension FilterCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ c: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let text = itemData[indexPath.item].label as NSString
        let font = UIFont.appFont(.pretendardBold, size: 14)
        let textWidth = text.size(withAttributes: [.font: font]).width
        let width = ceil(textWidth) + 39
        return CGSize(width: width, height: 34)
    }
}

