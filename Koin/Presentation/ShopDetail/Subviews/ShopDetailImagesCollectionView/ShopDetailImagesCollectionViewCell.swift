//
//  ShopDetailThumbnailCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit
import SnapKit
import Then

class ShopDetailImagesCollectionViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShopDetailImagesCollectionViewCell {
    
    func bind(url: String) {
        imageView.loadImage(from: url)
    }
    
    private func configureView() {
        [imageView].forEach {
            addSubview($0)
        }
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
