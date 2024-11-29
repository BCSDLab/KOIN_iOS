//
//  RelatedShopCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/14/24.
//

import Combine
import UIKit

final class RelatedShopCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.textColor = UIColor.appColor(.neutral500)
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        arrowImageView.image = nil
    }
    
    func configure(info: Keyword) {
        if info.shopIds == [] || info.shopIds == nil {
            imageView.image = UIImage.appImage(asset: .store)
            arrowImageView.image = UIImage.appImage(asset: .arrowUpLeft)
        } else {
            imageView.image = UIImage.appImage(asset: .menu)
            arrowImageView.image = UIImage()
        }
        nameLabel.text = info.keyword
    }
}

extension RelatedShopCollectionViewCell {
    private func setUpLayouts() {
        [imageView, nameLabel, arrowImageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(12)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(4)
            make.centerY.equalTo(self.snp.centerY)
        }
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.height.width.equalTo(16)
        }
    }
    
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

