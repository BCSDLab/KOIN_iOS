//
//  ZoomingView.swift
//  koin
//
//  Created by 김나훈 on 4/8/24.
//


import UIKit
import Combine

final class ZoomingView: UIView {
    
    let closeButtonPublisher = PassthroughSubject<Void, Never>()
    let nextButtonPublisher = PassthroughSubject<Void, Never>()
    let prevButtonPublisher = PassthroughSubject<Void, Never>()
    
    private var images: [UIImage?] = []
    private var currentIndex = 0
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.appImage(asset: .cancel), for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.right")?.withTintColor(UIColor.appColor(.neutral0), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 22
        button.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.5)
        return button
    }()
    
    private let prevButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left")?.withTintColor(UIColor.appColor(.neutral0), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 22
        button.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.5)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUpViews() {
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addSubview(collectionView)
        addSubview(closeButton)
        addSubview(nextButton)
        addSubview(prevButton)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.top.equalTo(self.snp.top)
            make.trailing.equalTo(self.snp.trailing)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(closeButton.snp.bottom).offset(8)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(self.snp.trailing)
            make.width.height.equalTo(44)
        }
        
        prevButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.snp.leading)
            make.width.height.equalTo(44)
        }
    }
    
    @objc private func closeButtonTapped() {
        closeButtonPublisher.send()
    }
    
    @objc private func nextButtonTapped() {
        
        if currentIndex < images.count - 1 {
            let nextIndexPath = IndexPath(row: currentIndex + 1, section: 0)
            collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
        currentIndex += 1
        updateButtonVisibility()
    }
    
    @objc private func prevButtonTapped() {
        
        if currentIndex > 0 {
            let prevIndexPath = IndexPath(row: currentIndex - 1, section: 0)
            collectionView.scrollToItem(at: prevIndexPath, at: .centeredHorizontally, animated: true)
        }
        currentIndex -= 1
        updateButtonVisibility()
    }
    
    func setImages(_ newImages: [UIImage?]) {
        currentIndex = 0
        images = newImages
        collectionView.reloadData()
        updateButtonVisibility()
    }
    
    func setImage(_ newImage: UIImage?) {
        currentIndex = 0
        images = [newImage]
        collectionView.reloadData()
        updateButtonVisibility()
    }
    
    private func updateButtonVisibility() {
        nextButton.isHidden = currentIndex >= images.count - 1
        prevButton.isHidden = currentIndex <= 0
    }
    
}

extension ZoomingView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue ImageCell")
        }
        cell.setImage(images[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

final class ImageCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}
