//
//  ShopCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 1/21/24.
//

import UIKit

final class ShopCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.lineBreakMode = .byClipping
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(info: ShopCategory) {
        titleLabel.text = info.name
        imageView.loadImage(from: info.imageURL)
    }
}

extension ShopCollectionViewCell {
    private func setUpLayouts() {
        [imageView, titleLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(11)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(45)
            make.width.equalTo(45)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.equalTo(self.snp.leading).offset(-10)
            make.trailing.equalTo(self.snp.trailing).offset(10)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
