//
//  ShopDetailThumbnailCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit
import SnapKit
import Kingfisher
import Then

final class ShopDetailImagesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Component
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(url: String?) {
        guard let url else {
            imageView.image = UIImage.appImage(asset: .defaultMenuImage)
            return
        }
        imageView.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage.appImage(asset: .defaultMenuImage)
        )
    }
}

extension ShopDetailImagesCollectionViewCell {

    private func configureView() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
