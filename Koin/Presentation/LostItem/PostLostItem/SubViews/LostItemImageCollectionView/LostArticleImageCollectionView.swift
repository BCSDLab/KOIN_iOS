//
//  LostArticleImageCollectionView.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine
import UIKit

final class LostItemImageCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let shouldDismissDropDownKeyBoardPublisher = PassthroughSubject<Void, Never>()
    let imageCountPublisher = PassthroughSubject<[String], Never>()
    private(set) var imageUrls: [String] = [] {
        didSet {
            imageCountPublisher.send(imageUrls)
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
        contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        register(LostItemImageCollectionViewCell.self, forCellWithReuseIdentifier: LostItemImageCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func addImageUrl(_ imageUrl: String) {
        self.imageUrls.append(imageUrl)
        self.reloadData()
    }
    
    func updateImageUrls(_ imageUrls: [String]) {
        self.imageUrls = imageUrls
        self.reloadData()
    }
}

extension LostItemImageCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LostItemImageCollectionViewCell.identifier, for: indexPath) as? LostItemImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(imageUrl: imageUrls[indexPath.row])
        cell.cancelButtonPublisher.sink { [weak self] in
            self?.imageUrls.remove(at: indexPath.row)
            self?.reloadData()
        }.store(in: &cell.cancellables)
        cell.shouldDismissDropDownKeyBoardPublisher.sink { [weak self] in
            self?.shouldDismissDropDownKeyBoardPublisher.send()
        }.store(in: &cell.cancellables)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 112, height: 99)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}


