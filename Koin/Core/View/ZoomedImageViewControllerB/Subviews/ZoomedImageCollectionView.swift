//
//  ZoomedImageCollectionView.swift
//  koin
//
//  Created by 홍기정 on 11/14/25.
//

import UIKit
import Combine

final class ZoomedImageCollectionView: UICollectionView {
    
    // MARK: - Properties
    private var urls: [String] = []
    private var initialIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    let updateTitlePublisher = PassthroughSubject<String, Never>()
    let hideNavigationBarPublisher = PassthroughSubject<Bool, Never>()
    private var isInitialized = false
    
    // MARK: - Initializer
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
        }
        super.init(frame: .zero, collectionViewLayout: layout)
        commonInit()
        configureCollectionView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(urls: [String], initialIndexPath: IndexPath) {
        self.urls = urls
        self.initialIndexPath = initialIndexPath
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isInitialized {
            contentOffset = CGPoint(x: UIScreen.main.bounds.width * CGFloat(initialIndexPath.row), y: 0)
            isInitialized = true
        }
    }
}

extension ZoomedImageCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZoomedImageCollectionViewCell.identifier, for: indexPath) as? ZoomedImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(url: urls[indexPath.row])
        return cell
    }
}

extension ZoomedImageCollectionView: UICollectionViewDelegateFlowLayout {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = self.frame.width
        let row = Int(contentOffset.x / width + 0.5)
        guard 0 <= row else {
            return
        }
        let title = "\(row + 1)/\(urls.count)"
        updateTitlePublisher.send(title)
    }
}

extension ZoomedImageCollectionView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        register(ZoomedImageCollectionViewCell.self, forCellWithReuseIdentifier: ZoomedImageCollectionViewCell.identifier)
    }
    
    private func configureCollectionView() {
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        backgroundColor = .black
    }
}
