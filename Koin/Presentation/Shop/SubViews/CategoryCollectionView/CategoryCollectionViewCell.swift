//
//  CategoryCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Component
    private let imageView = UIImageView().then {
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.lineBreakMode = .byClipping
        $0.sizeToFit()
    }

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
        titleLabel.textColor = selected ? UIColor.appColor(.sub500) : UIColor.appColor(.neutral800)
        if selected { titleLabel.textColor = UIColor.appColor(.sub500) }
    }
}

extension CategoryCollectionViewCell {
    private func setUpLayouts() {
        [imageView, titleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.width.equalToSuperview()
            make.centerX.equalTo(contentView.snp.centerX)
            make.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.height.equalTo(19)
            make.centerX.equalTo(imageView.snp.centerX)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
