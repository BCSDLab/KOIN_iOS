//
//  CallBenefitCollectionView.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Combine
import UIKit

final class CallBenefitCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(ShopInfoCollectionViewCell.self, forCellWithReuseIdentifier: ShopInfoCollectionViewCell.identifier)
        register(CallBenefitFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CallBenefitFooterView.identifier)
        dataSource = self
        delegate = self
    }
    
    func updateBenefits() {
        self.reloadData()
    }
    
}

extension CallBenefitCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CallBenefitFooterView.identifier, for: indexPath) as? CallBenefitFooterView else {
                return UICollectionReusableView()
            }
            
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CallBenefitCollectionViewCell.identifier, for: indexPath) as? CallBenefitCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure()
        return cell
    }
}
