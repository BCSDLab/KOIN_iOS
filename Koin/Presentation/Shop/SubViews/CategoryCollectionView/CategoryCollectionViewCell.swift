//
//  CategoryCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Component
    private let imageBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 8
    }
    
    private let imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.lineBreakMode = .byClipping
        $0.sizeToFit()
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(info: ShopCategory, _ selected: Bool) {
        imageView.loadImage(from: info.imageURL)
        titleLabel.text = info.name
    }
}

extension CategoryCollectionViewCell {
    private func setUpLayouts() {
        [imageBackgroundView, imageView, titleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalTo(contentView.snp.centerX)
            make.width.height.equalTo(48)
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(imageBackgroundView.snp.centerY)
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageBackgroundView.snp.bottom).offset(8)
            make.height.equalTo(19)
            make.centerX.equalTo(imageBackgroundView.snp.centerX)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
