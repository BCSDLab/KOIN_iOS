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
        
        DispatchQueue.main.async { [weak self] in
            guard menuGroup.count != 0 else { return }
            
            self?.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
            self?.configureSelectedCell(IndexPath(row: 0, section: 0))
        }
    }
}

extension ShopDetailMenuGroupCollectionView {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        configureSelectedCell(indexPath)
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
    
    func configureSelectedCell(_ indexPath: IndexPath) {
        guard let cell = cellForItem(at: indexPath) as? ShopDetailMenuGroupCollectionViewCell else {
            return
        }
        cell.label.textColor = .appColor(.new500)
        cell.layer.borderColor = UIColor.appColor(.new500).cgColor
        cell.layer.borderWidth = 1
        cell.layer.applySketchShadow(color: .clear, alpha: 0, x: 0, y: 0, blur: 0, spread: 0)
    }
    func configureDeselectedCell(_ indexPath: IndexPath) {
        guard let cell = cellForItem(at: indexPath) as? ShopDetailMenuGroupCollectionViewCell else {
            return
        }
        cell.label.textColor = .appColor(.neutral400)
        cell.layer.borderColor = .none
        cell.layer.borderWidth = 0
        cell.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 1, blur: 1, spread: 0)
        cell.layer.shadowRadius = 17
    }
}

extension ShopDetailMenuGroupCollectionView {
    
    private func commonInit() {
        self.delegate = self
        self.dataSource = self
        register(ShopDetailMenuGroupCollectionViewCell.self, forCellWithReuseIdentifier: ShopDetailMenuGroupCollectionViewCell.identifier)
    }
}
