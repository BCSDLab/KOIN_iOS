//
//  OrderCartListCellPriceTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//

import UIKit

final class OrderCartListCellPriceTableViewCell: UITableViewCell {
    
    // MARK: - Components
    private let label = UILabel().then {
        $0.textColor = .appColor(.neutral500)
        $0.font = .appFont(.pretendardRegular, size: 13)
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
    
    func configure(option: Option) {
        let formatter = NumberFormatter().then {
            $0.numberStyle = .decimal
        }
        var text = option.optionGroupName + " : " + option.optionName
        if(option.optionPrice != 0) {
            let price: String = formatter.string(from: NSNumber(value: option.optionPrice)) ?? "-"
            text += " (\(price)원)"
        }
        label.text = text
    }
}

extension OrderCartListCellPriceTableViewCell {
    
    private func setUpLayout() {
        [label].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}
