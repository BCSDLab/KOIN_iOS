//
//  CallVanListCollectionView.swift
//  koin
//
//  Created by 홍기정 on 3/3/26.
//

import UIKit
import Combine
import Then

final class CallVanListCollectionView: UICollectionView {
    
    // MARK: - Properties
    let mainButtonTappedPublisher = PassthroughSubject<(Int, CallVanState), Never>()
    let subButtonTappedPublisher = PassthroughSubject<(Int, CallVanState), Never>()
    let chatButtonTappedPublisher = PassthroughSubject<Int, Never>()
    let callButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let postTappedPublisher = PassthroughSubject<Int, Never>()
    private var subscriptions: Set<AnyCancellable> = []
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
        register(CallVanListCollectionViewCell.self, forCellWithReuseIdentifier: CallVanListCollectionViewCell.identifier)
    }
}

extension CallVanListCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 103)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if posts[indexPath.row].showChatButton || posts[indexPath.row].showCallButton {
            postTappedPublisher.send(posts[indexPath.row].postId)
        }
        deselectItem(at: indexPath, animated: true)
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
        bind(cell)
        return cell
    }
    
    private func bind(_ cell: CallVanListCollectionViewCell) {
        cell.mainButtonTappedPublisher.sink { [weak self] postId in
            guard let self else { return }
            if let mainState = posts.first(where: { $0.postId == postId })?.mainState {
                mainButtonTappedPublisher.send((postId, mainState))
            }
        }.store(in: &cell.subscriptions)
        
        cell.subButtonTappedPublisher.sink { [weak self] postId in
            guard let self else { return }
            if let subState = posts.first(where: { $0.postId == postId })?.subState {
                subButtonTappedPublisher.send((postId, subState))
            }
        }.store(in: &cell.subscriptions)
        
        cell.chatButtonTappedPublisher.sink { [weak self] postId in
            self?.chatButtonTappedPublisher.send(postId)
        }.store(in: &cell.subscriptions)
        
        cell.callButtonTappedPublisher.sink { [weak self] in
            self?.callButtonTappedPublisher.send()
        }.store(in: &cell.subscriptions)
    }
}
