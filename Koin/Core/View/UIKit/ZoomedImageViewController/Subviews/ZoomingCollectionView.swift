//
//  ZoomingCollectionView.swift
//  koin
//
//  Created by 홍기정 on 4/22/26.
//

import UIKit
import Combine

final class ZoomingCollectionView: UICollectionView {
    
    private var images: [UIImage?] = []
    let closeButtonPublisher = PassthroughSubject<Void, Never>()
    
    var imageCount: Int {
        images.count
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        super.init(frame: .zero, collectionViewLayout: layout)
        setUpCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImages(_ newImages: [UIImage?]) {
        images = newImages
        reloadData()
        setContentOffset(.zero, animated: false)
    }
    
    func setImage(_ newImage: UIImage?) {
        setImages([newImage])
    }
    
    func showImage(at index: Int, animated: Bool) {
        guard 0..<images.count ~= index else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
}

extension ZoomingCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ZoomingCollectionViewCell.identifier,
            for: indexPath
        ) as? ZoomingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setImage(images[indexPath.row])
        cell.onCloseButtonTap = { [weak self] in
            self?.closeButtonPublisher.send()
        }
        return cell
    }
}

extension ZoomingCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }
}

extension ZoomingCollectionView {
    
    private func setUpCollectionView() {
        register(
            ZoomingCollectionViewCell.self,
            forCellWithReuseIdentifier: ZoomingCollectionViewCell.identifier
        )
        delegate = self
        dataSource = self
        isPagingEnabled = true
        isScrollEnabled = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        backgroundColor = .clear
    }
}
