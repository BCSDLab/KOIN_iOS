//
//  ShopSearchTableViewMenuNameCell.swift
//  koin
//
//  Created by 홍기정 on 11/8/25.
//

import UIKit
import Then
import SnapKit

final class ShopSearchTableViewMenuNameCell: UITableViewCell {
    
    // MARK: - UI Components
    let menuImageView = UIImageView(image: UIImage.appImage(asset: .menu))
    let menuNameLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral500)
        $0.numberOfLines = 1
    }
    let separatorLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral500)
        $0.text = "|"
    }
    let shopNameLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral500)
        $0.numberOfLines = 1
        $0.textAlignment = .left
    }
    let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        contentView.backgroundColor = .appColor(.newBackground)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(menuName: String, shopName: String) {
        menuNameLabel.text = menuName
        shopNameLabel.text = shopName
    }
    
}

extension ShopSearchTableViewMenuNameCell {
    
    private func setUpLayout() {
        [menuImageView,
         menuNameLabel,
         separatorLabel,
         shopNameLabel,
         separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        menuImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
        }
        menuNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(28)
        }
        separatorLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(menuNameLabel.snp.trailing).offset(4)
        }
        shopNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(separatorLabel.snp.trailing).offset(4)
            $0.trailing.equalToSuperview()
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

