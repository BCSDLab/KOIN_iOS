//
//  ZoomedImageCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 11/14/25.
//

import UIKit

final class ZoomedImageCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Components
    private let zoomableImageView = ZoomableImageView()

    var isZoomed: Bool {
        zoomableImageView.isZoomed
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(url: String) {
        zoomableImageView.setImage(url: url)
    }

    func resetZoom() {
        zoomableImageView.resetZoom()
    }

    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        zoomableImageView.setImage(nil)
    }
}

extension ZoomedImageCollectionViewCell {

    private func configureView() {
        contentView.addSubview(zoomableImageView)
        zoomableImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
