//
//  BannerCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 4/1/25.
//

import UIKit

final class BannerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let imageView = UIImageView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(_ item: Banner) {
        imageView.loadImageWithSpinner(from: item.imageURL)
    }
    
}

extension BannerCollectionViewCell {
    private func setUpLayouts() {
        [imageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }


    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

