//
//  AddMenuCollectionView.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine
import UIKit

final class AddMenuCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let menuItemCountPublisher = PassthroughSubject<Int, Never>()
    private var menuItem: [String] = [] {
        didSet {
            menuItemCountPublisher.send(menuItem.count)
            reloadData()
        }
    }
    
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
        register(AddMenuCollectionViewCell.self, forCellWithReuseIdentifier: AddMenuCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func addMenuItem() {
        menuItem.append("")
    }
    
}

extension AddMenuCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddMenuCollectionViewCell.identifier, for: indexPath) as? AddMenuCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.cancelButtonPublisher.sink { [weak self] in
            
        }.store(in: &cell.cancellables)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(collectionView.bounds.width), height: 46)
    }
    
}




