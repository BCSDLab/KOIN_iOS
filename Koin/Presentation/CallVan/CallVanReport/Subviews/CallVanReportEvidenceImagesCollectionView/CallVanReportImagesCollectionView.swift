//
//  CallVanReportImagesCollectionView.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import Combine
import UIKit

final class CallVanReportImagesCollectionView: UICollectionView {
    
    // MARK: - Properties
    let imageCountPublisher = PassthroughSubject<[String], Never>()
    private(set) var imageUrls: [String] = [] {
        didSet {
            imageCountPublisher.send(imageUrls)
        }
    }
    
    // MARK: - Initializer
    init() {
        let layout = UICollectionViewFlowLayout().then {
            $0.minimumInteritemSpacing = 8
            $0.itemSize = CGSize(width: 112, height: 99)
        }
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func addImageUrl(_ imageUrl: String) {
        imageUrls.append(imageUrl)
        reloadData()
    }
}

extension CallVanReportImagesCollectionView {
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        register(CallVanReportImagesCollectionViewCell.self, forCellWithReuseIdentifier: CallVanReportImagesCollectionViewCell.identifier)
        dataSource = self
    }
}

extension CallVanReportImagesCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CallVanReportImagesCollectionViewCell.identifier,
            for: indexPath
        ) as? CallVanReportImagesCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(imageUrl: imageUrls[indexPath.row])
        bind(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageUrls.count
    }
}

extension CallVanReportImagesCollectionView {

    private func bind(_ cell: CallVanReportImagesCollectionViewCell) {
        cell.cancelButtonPublisher.sink { [weak self] imageUrl in
            guard let self else { return }
            imageUrls = imageUrls.filter { $0 != imageUrl }
            reloadData()
        }.store(in: &cell.subscriptions)
    }
}
