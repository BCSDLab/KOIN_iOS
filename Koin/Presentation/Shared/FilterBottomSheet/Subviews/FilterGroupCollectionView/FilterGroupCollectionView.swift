//
//  FilterGroupCollectionView.swift
//  koin
//
//  Created by 홍기정 on 8/27/26.
//

import UIKit
import Combine

final class FilterGroupCollectionView: UICollectionView {
    
    // MARK: - Publisher
    let itemTappedPublisher = PassthroughSubject<Int, Never>()
    
    // MARK: - Properties
    private(set) var filterGroup: FilterGroupModel
    
    // MARK: - Initializer
    init(filterGroup: FilterGroupModel) {
        self.filterGroup = filterGroup
        super.init(
            frame: .zero,
            collectionViewLayout: LeftAlignedFlowLayout()
        )
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func update(filterGroup: FilterGroupModel, changed indexPaths: [IndexPath]) {
        self.filterGroup = filterGroup
        reconfigureItems(at: indexPaths)
    }
    
    // MARK: - Override
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: collectionViewLayout.collectionViewContentSize.height
        )
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.height != collectionViewLayout.collectionViewContentSize.height {
            invalidateIntrinsicContentSize()
        }
    }
}

extension FilterGroupCollectionView {
    private func commonInit() {
        isScrollEnabled = false
        delegate = self
        dataSource = self
        register(
            FilterGroupCollectionViewCell.self,
            forCellWithReuseIdentifier: FilterGroupCollectionViewCell.identifier
        )
    }
}

extension FilterGroupCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: false)
        itemTappedPublisher.send(indexPath.row)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let title = filterGroup.items[indexPath.row].title
        let titleWidth = (title as NSString).size(
            withAttributes: [.font: UIFont.appFont(.pretendardSemiBold, size: 14)]
        ).width
        return CGSize(
            width: ceil(titleWidth) + 12 * 2,
            height: 34
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }
}

extension FilterGroupCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterGroup.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilterGroupCollectionViewCell.identifier,
            for: indexPath
        ) as? FilterGroupCollectionViewCell else {
            return UICollectionViewCell()
        }
        let index = indexPath.row
        cell.configure(item: filterGroup.items[index])
        return cell
    }
}
