//
//  ZoomingCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 4/22/26.
//

import UIKit

final class ZoomingCollectionViewCell: UICollectionViewCell {
    
    var onCloseButtonTap: (() -> Void)?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var imageAspectRatioConstraint: NSLayoutConstraint?
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.appImage(asset: .cancel), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        onCloseButtonTap = nil
        imageAspectRatioConstraint?.isActive = false
        imageAspectRatioConstraint = nil
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
        
        imageAspectRatioConstraint?.isActive = false
        if let image, image.size.width > 0 {
            let ratio = image.size.height / image.size.width
            let constraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio)
            constraint.priority = .defaultHigh
            constraint.isActive = true
            imageAspectRatioConstraint = constraint
        }
    }
    
    @objc private func closeButtonTapped() {
        onCloseButtonTap?()
    }
}

extension ZoomingCollectionViewCell {
    
    private func configureView() {
        contentView.addSubview(imageView)
        contentView.addSubview(closeButton)
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(contentView.safeAreaLayoutGuide.snp.top).offset(24)
            make.bottom.lessThanOrEqualTo(contentView.safeAreaLayoutGuide.snp.bottom)
        }
        
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.bottom.equalTo(imageView.snp.top).offset(-8)
            make.trailing.equalTo(imageView.snp.trailing)
        }
    }
}
