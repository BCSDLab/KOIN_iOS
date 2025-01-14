//
//  LostArticleImageCollectionView.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine
import UIKit

final class LostArticleImageCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let imageCountPublisher = PassthroughSubject<Int, Never>()
    private(set) var imageUrls: [String] = [] {
        didSet {
            imageCountPublisher.send(imageUrls.count)
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
        register(LostArticleImageCollectionViewCell.self, forCellWithReuseIdentifier: LostArticleImageCollectionViewCell.identifier)
        register(LostArticleImageCollectionViewCell.self, forCellWithReuseIdentifier: LostArticleImageCollectionViewCell.identifier)
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

extension LostArticleImageCollectionView {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LostArticleImageCollectionViewCell.identifier, for: indexPath) as? LostArticleImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(imageUrl: imageUrls[indexPath.row])
        cell.cancelButtonPublisher.sink { [weak self] in
            self?.imageUrls.remove(at: indexPath.row)
            self?.reloadData()
        }.store(in: &cell.cancellables)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int((collectionView.bounds.width - 38) / 3)
        return CGSize(width: width, height: Int(collectionView.bounds.height) - 16)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}


