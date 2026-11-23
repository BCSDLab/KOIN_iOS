//
//  LandDetailImageCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import SnapKit
import Kingfisher

final class LandDetailImageCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Components
    private let imageView = UIImageView()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandDetailImageCollectionViewCell {
    func configure(imageUrl: String) {
        imageView.kf.setImage(with: URL(string: imageUrl))
    }
}

extension LandDetailImageCollectionViewCell {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
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
