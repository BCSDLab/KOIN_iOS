//
//  MenuImageCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
//

import Combine
import UIKit

final class MenuImageCollectionView: UICollectionView, UICollectionViewDataSource {
    
    private var imageList: [String] = []
    var didSelectImage = PassthroughSubject<UIImage?, Never>()
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
        register(MenuImageCollectionViewCell.self, forCellWithReuseIdentifier: MenuImageCollectionViewCell.identifier)
        dataSource = self
        isScrollEnabled = true
    }
    
    func setImageList(_ list: [String]) {
        imageList = list
        self.reloadData()
    }
    
}

extension MenuImageCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuImageCollectionViewCell.identifier, for: indexPath) as? MenuImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageItem = imageList[indexPath.row]
        cell.configure(imageURL: imageItem)
        cell.imageTapPublisher
            .sink { [weak self] image in
                self?.didSelectImage.send(image)
            }
            .store(in: &cancellables)
        return cell
    }
}
