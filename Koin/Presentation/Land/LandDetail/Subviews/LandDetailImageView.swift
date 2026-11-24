//
//  LandDetailImageView.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import Combine
import SnapKit

final class LandDetailImageView: UIView {

    // MARK: - Properties
    let imageTappedPublisher = PassthroughSubject<([String], IndexPath), Never>()
    private var imageUrls: [String] = []

    // MARK: - UI Components
    private let stackView = UIStackView()
    private let imageContainerView = UIView()
    private let collectionViewLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    private let emptyView = LandDetailImageEmptyView()
    private let pageControl = UIPageControl()

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if collectionViewLayout.itemSize != collectionView.bounds.size {
            collectionViewLayout.itemSize = collectionView.bounds.size
            collectionViewLayout.invalidateLayout()
        }
    }
}

extension LandDetailImageView {
    func configure(imageUrls: [String]) {
        self.imageUrls = imageUrls
        collectionView.reloadData()
        collectionView.isHidden = imageUrls.isEmpty
        emptyView.isHidden = !imageUrls.isEmpty
        pageControl.numberOfPages = imageUrls.count
        pageControl.currentPage = 0
        pageControl.isHidden = imageUrls.count <= 1
    }
}

extension LandDetailImageView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LandDetailImageCollectionViewCell.identifier, for: indexPath) as? LandDetailImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(imageUrl: imageUrls[indexPath.item])
        return cell
    }
}

extension LandDetailImageView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageTappedPublisher.send((imageUrls, indexPath))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width > 0 else { return }
        pageControl.currentPage = Int((scrollView.contentOffset.x / scrollView.bounds.width).rounded())
    }
}

extension LandDetailImageView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        stackView.axis = .vertical
        imageContainerView.backgroundColor = UIColor(hexCode: "F8F8F8")
        collectionViewLayout.do {
            $0.scrollDirection = .horizontal
            $0.minimumLineSpacing = 0
        }
        collectionView.do {
            $0.register(LandDetailImageCollectionViewCell.self, forCellWithReuseIdentifier: LandDetailImageCollectionViewCell.identifier)
            $0.dataSource = self
            $0.delegate = self
            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = UIColor(hexCode: "F8F8F8")
            $0.isHidden = true
        }
        emptyView.isHidden = true
        pageControl.do {
            $0.pageIndicatorTintColor = .appColor(.neutral300)
            $0.currentPageIndicatorTintColor = .appColor(.new400)
            $0.isUserInteractionEnabled = false
            $0.isHidden = true
        }
    }

    private func setUpLayouts() {
        addSubview(stackView)
        [imageContainerView, pageControl].forEach {
            stackView.addArrangedSubview($0)
        }
        [collectionView, emptyView].forEach {
            imageContainerView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        imageContainerView.snp.makeConstraints {
            $0.height.equalTo(imageContainerView.snp.width).multipliedBy(9.0 / 16.0)
        }
        [collectionView, emptyView].forEach {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        pageControl.snp.makeConstraints {
            $0.height.equalTo(30)
        }
    }
}
