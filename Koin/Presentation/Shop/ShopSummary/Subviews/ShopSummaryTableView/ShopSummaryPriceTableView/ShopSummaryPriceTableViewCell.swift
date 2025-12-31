//
//  ShopSummaryPriceTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/23/25.
//

import UIKit
import SnapKit

final class ShopSummaryPriceTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let stackView = UIStackView().then {
        $0.alignment = .fill
        $0.spacing = 0
    }
    private let nameLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.contentMode = .center
        $0.textAlignment = .left
    }
    private let priceLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .appFont(.pretendardSemiBold, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.contentMode = .center
        $0.textAlignment = .left
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(price: Price){
        if let name = price.name {
            nameLabel.text = "\(name) : "
            nameLabel.isHidden = false
        } else {
            nameLabel.isHidden = true
        }
        
        let formatter = NumberFormatter().then {
            $0.numberStyle = .decimal
        }
        let price = formatter.string(from: NSNumber(value: price.price)) ?? ""
        priceLabel.text = "\(price)원"
    }
}

extension ShopSummaryPriceTableViewCell {
    
    private func configureView() {
        [nameLabel, priceLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
    }
}
