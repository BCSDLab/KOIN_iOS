//
//  ShopDetailMenuGroupCollectionView.swift
//  koin
//
//  Created by 홍기정 on 9/8/25.
//

import UIKit
import Combine

final class ShopDetailMenuGroupCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Properties
    private var menuGroup: [MenuGroup] = []
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
    
    func configure(menuGroup: [MenuGroup]) {
        self.menuGroup = menuGroup
        
        self.reloadData()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        guard menuGroup.count != 0 else { return }
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

extension ShopDetailMenuGroupCollectionView {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        configureSelectedCell(indexPath)
        shouldSetContentInset.send(true)
        didSelectCellPublisher.send(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        configureDeselectedCell(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuGroup.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopDetailMenuGroupCollectionViewCell.identifier, for: indexPath) as? ShopDetailMenuGroupCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(menuGroup[indexPath.row].name)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel().then {
            $0.text = menuGroup[indexPath.row].name
            $0.font = .appFont(.pretendardSemiBold, size: 14)
        }
        return CGSize(width: label.intrinsicContentSize.width + 24, height: 34)
    }
}

extension ShopDetailMenuGroupCollectionView {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = self.contentOffset
        didScrollPublisher.send(contentOffset)
    }
}

extension ShopDetailMenuGroupCollectionView {
    
    private func configureSelectedCell(_ indexPath: IndexPath) {
        if let cell = cellForItem(at: indexPath) as? ShopDetailMenuGroupCollectionViewCell {
            cell.setSelected(isSelected: true)
        }
    }
    private func configureDeselectedCell(_ indexPath: IndexPath) {
        if let cell = cellForItem(at: indexPath) as? ShopDetailMenuGroupCollectionViewCell {
            cell.setSelected(isSelected: false)
        }
    }
}

extension ShopDetailMenuGroupCollectionView {
    
    private func commonInit() {
        self.delegate = self
        self.dataSource = self
        register(ShopDetailMenuGroupCollectionViewCell.self, forCellWithReuseIdentifier: ShopDetailMenuGroupCollectionViewCell.identifier)
    }
}
