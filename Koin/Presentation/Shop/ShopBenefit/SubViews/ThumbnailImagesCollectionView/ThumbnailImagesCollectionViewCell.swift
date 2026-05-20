//
//  ThumbnailImagesCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 5/19/26.
//

import SnapKit
import Then
import UIKit

final class ThumbnailImagesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    // MARK: - Public
    func configure(imageUrl: String) {
        imageView.loadImageWithSpinner(from: imageUrl)
    }
}

extension ThumbnailImagesCollectionViewCell {
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        contentView.addSubview(imageView)
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
