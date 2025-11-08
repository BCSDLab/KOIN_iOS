//
//  ShopSearchShopNameCell.swift
//  koin
//
//  Created by 홍기정 on 11/8/25.
//

import UIKit
import Then
import SnapKit

final class ShopSearchTableViewShopNameCell: UITableViewCell {
    
    // MARK: - UI Components
    let storeImageView = UIImageView(image: UIImage.appImage(asset: .store))
    let shopNameLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral500)
    }
    let arrowUpLeftImageView = UIImageView(image: .appImage(asset: .arrowUpLeft))
    let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(shopName: String) {
        shopNameLabel.text = shopName
    }
    
}

extension ShopSearchTableViewShopNameCell {
    
    private func setUpLayout() {
        [storeImageView,
         shopNameLabel,
         arrowUpLeftImageView,
         separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        storeImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
        }
        shopNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(28)
        }
        arrowUpLeftImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-8)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}

