//
//  LostItemImagesCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 1/19/26.
//

import UIKit
import SnapKit
import Kingfisher
import Then

final class LostItemImagesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
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
            imageView.image = UIImage()
            return
        }
        imageView.kf.setImage(
            with: URL(string: url)
        )
    }
}

extension LostItemImagesCollectionViewCell {

    private func configureView() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
