//
//  ShopDetailMenuGroupCollectionView.swift
//  koin
//
//  Created by 홍기정 on 9/8/25.
//

import UIKit

class ShopDetailMenuGroupCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Properties
    private var menuGroupName: [String] = []
    
    // MARK: - Initiailizer
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: layout)
        setCollectionView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind(menuGroupName: [String]) {
        self.menuGroupName = menuGroupName
        self.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            guard !menuGroupName.isEmpty else { return }
            self?.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
            self?.configureSelectedCell(IndexPath(row: 0, section: 0))
        }
    }
}

extension ShopDetailMenuGroupCollectionView {
    
    private func setCollectionView() {
        self.delegate = self
        self.dataSource = self
        register(ShopDetailMenuGroupCollectionViewCell.self, forCellWithReuseIdentifier: ShopDetailMenuGroupCollectionViewCell.identifier)
    }
}

extension ShopDetailMenuGroupCollectionView {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        configureSelectedCell(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        configureDeselectedCell(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuGroupName.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopDetailMenuGroupCollectionViewCell.identifier, for: indexPath) as? ShopDetailMenuGroupCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.bind(menuGroupName[indexPath.row])
        cell.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel().then {
            $0.text = menuGroupName[indexPath.row]
            $0.font = .appFont(.pretendardSemiBold, size: 14)
        }
        return CGSize(width: label.intrinsicContentSize.width + 24, height: 34)
    }
}

extension ShopDetailMenuGroupCollectionView {
    
    private func configureSelectedCell(_ indexPath: IndexPath) {
        guard let cell = cellForItem(at: indexPath) as? ShopDetailMenuGroupCollectionViewCell else {
            return
        }
        cell.label.textColor = .appColor(.new500)
        cell.layer.borderColor = UIColor.appColor(.new500).cgColor
        cell.layer.borderWidth = 1
    }
    private func configureDeselectedCell(_ indexPath: IndexPath) {
        guard let cell = cellForItem(at: indexPath) as? ShopDetailMenuGroupCollectionViewCell else {
            return
        }
        cell.label.textColor = .appColor(.neutral400)
        cell.layer.borderColor = .none
        cell.layer.borderWidth = 0
    }
}
