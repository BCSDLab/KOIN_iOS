//
//  ShopSummaryMenuGroupCollectionView.swift
//  koin
//
//  Created by 홍기정 on 9/8/25.
//

import UIKit
import Combine

final class ShopSummaryMenuGroupCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Properties
    private var menuGroups: [ShopMenuGroup] = []
    let didScrollPublisher = PassthroughSubject<CGPoint, Never>()
    let didSelectCellPublisher = PassthroughSubject<IndexPath, Never>()
    let shouldSetContentInset = PassthroughSubject<Bool, Never>()
    
    // MARK: - Initiailizer
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(menuGroups: [ShopMenuGroup]) {
        self.menuGroups = menuGroups
        
        self.reloadData()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        guard menuGroups.count != 0 else { return }
        self.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        self.configureSelectedCell(IndexPath(row: 0, section: 0))
    }
    func configure(selectedIndexPath indexPath: IndexPath) {
        indexPathsForSelectedItems?.forEach {
            configureDeselectedCell($0)
        }
        configureSelectedCell(indexPath)
    }
}

extension ShopSummaryMenuGroupCollectionView {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        configureSelectedCell(indexPath)
        shouldSetContentInset.send(true)
        didSelectCellPublisher.send(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        configureDeselectedCell(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuGroups.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopSummaryMenuGroupCollectionViewCell.identifier, for: indexPath) as? ShopSummaryMenuGroupCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(menuGroups[indexPath.row].name)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel().then {
            $0.text = menuGroups[indexPath.row].name
            $0.font = .appFont(.pretendardSemiBold, size: 14)
        }
        return CGSize(width: label.intrinsicContentSize.width + 24, height: 34)
    }
}

extension ShopSummaryMenuGroupCollectionView {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = self.contentOffset
        didScrollPublisher.send(contentOffset)
    }
}

extension ShopSummaryMenuGroupCollectionView {
    
    private func configureSelectedCell(_ indexPath: IndexPath) {
        if let cell = cellForItem(at: indexPath) as? ShopSummaryMenuGroupCollectionViewCell {
            cell.setSelected(isSelected: true)
        }
    }
    private func configureDeselectedCell(_ indexPath: IndexPath) {
        if let cell = cellForItem(at: indexPath) as? ShopSummaryMenuGroupCollectionViewCell {
            cell.setSelected(isSelected: false)
        }
    }
}

extension ShopSummaryMenuGroupCollectionView {
    
    private func commonInit() {
        self.delegate = self
        self.dataSource = self
        register(ShopSummaryMenuGroupCollectionViewCell.self, forCellWithReuseIdentifier: ShopSummaryMenuGroupCollectionViewCell.identifier)
    }
}
