//
//  TimetableCollectionView.swift
//  koin
//
//  Created by 김나훈 on 11/9/24.
//

import UIKit

final class TimetableCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var somethings: [Any] = []
    
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
        register(TimetableCollectionViewCell.self, forCellWithReuseIdentifier: TimetableCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func setUpSomethings() {
      
        reloadData()
    }
    
}

extension TimetableCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return somethings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimetableCollectionViewCell.identifier, for: indexPath) as? TimetableCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure()
        return cell
    }
}
