//
//  CallVanListCollectionView.swift
//  koin
//
//  Created by 홍기정 on 3/3/26.
//

import UIKit

final class CallVanListCollectionView: UICollectionView {
    
    // MARK: - Properties
    private var posts: [CallVanListPost] = []
    
    // MARK: - Initializer
    init() {
        super.init(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout().then {
                $0.scrollDirection = .vertical
                $0.minimumLineSpacing = 16
            }
        )
        contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(posts: [CallVanListPost]) {
        self.posts = posts
        reloadData()
    }
}

extension CallVanListCollectionView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        allowsSelection = false
        register(CallVanListCollectionViewCell.self, forCellWithReuseIdentifier: CallVanListCollectionViewCell.identifier)
    }
}

extension CallVanListCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 103)
    }
}

extension CallVanListCollectionView: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return posts.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CallVanListCollectionViewCell.identifier, for: indexPath) as? CallVanListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(posts[indexPath.row])
        return cell
    }
}
