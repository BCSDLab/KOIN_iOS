//
//  ImageScrollCollectionView.swift
//  koin
//
//  Created by 김나훈 on 1/16/25.
//

import Combine
import SnapKit
import UIKit

final class ImageScrollCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    private var imageUrls: [String] = []
    let currentPagePublisher = PassthroughSubject<Int, Never>()
    let imageTapPublisher = PassthroughSubject<UIImage, Never>()
    
    //MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: flowLayout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(ImageScrollCollectionViewCell.self, forCellWithReuseIdentifier: ImageScrollCollectionViewCell.identifier)
        decelerationRate = .normal
        dataSource = self
        delegate = self
        decelerationRate = .fast
        isPagingEnabled = true
    }
    func setImageUrls(urls: [String]) {
        self.imageUrls = urls
        reloadData()
    }
}


extension ImageScrollCollectionView {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        currentPagePublisher.send(currentPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageScrollCollectionViewCell.identifier, for: indexPath) as? ImageScrollCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.imageTapPublisher.sink { [weak self] image in
            self?.imageTapPublisher.send(image)
        }.store(in: &cell.cancellables)
        cell.configure(imageUrl: imageUrls[indexPath.row])
        return cell
    }
    
}

extension ImageScrollCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
