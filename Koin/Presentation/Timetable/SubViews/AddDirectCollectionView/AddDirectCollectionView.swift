//
//  AddDirectCollectionView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class AddDirectCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var somethings: [Int] = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
    let completeButtonPublisher = PassthroughSubject<Void, Never>()
    let addDirectButtonPublisher = PassthroughSubject<Void, Never>()
    let addClassButtonPublisher = PassthroughSubject<Void, Never>()
    let didTapCellPublisher = PassthroughSubject<Void, Never>()
    let filterButtonPublisher = PassthroughSubject<Void, Never>()
    private var headerCancellables = Set<AnyCancellable>()
    private var footerCancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        isScrollEnabled = true
        register(AddDirectCollectionViewCell.self, forCellWithReuseIdentifier: AddDirectCollectionViewCell.identifier)
        register(AddDirectHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AddDirectHeaderView.identifier)
        register(AddDirectFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AddDirectFooterView.identifier)
        dataSource = self
        delegate = self
    }
    
    func setUpSomethings() {
        
        reloadData()
    }
    
}

extension AddDirectCollectionView {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 84)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return somethings.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddDirectHeaderView.identifier, for: indexPath) as? AddDirectHeaderView else {
                return UICollectionReusableView()
            }
            headerCancellables.removeAll()
           //
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddDirectFooterView.identifier, for: indexPath) as? AddDirectFooterView else {
                return UICollectionReusableView()
            }
            footerCancellables.removeAll()
            //
            return footerView
        }
        return UICollectionReusableView()
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddDirectCollectionViewCell.identifier, for: indexPath) as? AddDirectCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: String(somethings[indexPath.row]))
        return cell
    }
}
