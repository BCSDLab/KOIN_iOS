//
//  OrderCategoryCollectionViewCell.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit
import SnapKit

final class OrderCategoryCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Component
    private let indicatorView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
        $0.layer.cornerRadius = 24
    }
    
    private let imageView = UIImageView().then {
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.lineBreakMode = .byClipping
        $0.sizeToFit()
    }
    
    // MARK: - Initialization
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
        indicatorView.isHidden = !selected
    }
}

extension OrderCategoryCollectionViewCell {
    private func setUpLayouts() {
        [indicatorView, imageView, titleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        indicatorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalTo(indicatorView)
            $0.centerY.equalTo(indicatorView)
            $0.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.height.equalTo(19)
            $0.centerX.equalTo(imageView.snp.centerX)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
