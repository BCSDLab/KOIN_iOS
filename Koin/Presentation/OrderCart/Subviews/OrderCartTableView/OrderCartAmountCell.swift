//
//  OrderCartAmountCell.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//

import UIKit

final class OrderCartAmountCell: UITableViewCell {
    
    // MARK: - Properties
    
    // MARK: - Components
    private let insetBackgroundView = UIView().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.layer.masksToBounds = false
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
    }
    private let totalAmountLabel = UILabel().then {
        $0.text = "총 금액"
    }
    private let totalAmountValueLabel = UILabel()
    private let itemsAmountLabel = UILabel().then {
        $0.text = "메뉴 금액"
    }
    private let itemsAmountValueLabel = UILabel()
    private let deliveryFeeLabel = UILabel().then {
        $0.text = "배달 금액"
    }
    private let deliveryFeeValueLabel = UILabel()
    private let finalPaymentAmountLabel = UILabel().then {
        $0.text = "결제예정금액"
    }
    private let finalPaymentAmountValueLabel = UILabel()
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(itemsAmount: Int, deliveryFee: Int, totalAmount: Int, finalPaymentAmount: Int) {
        let formatter = NumberFormatter().then {
            $0.numberStyle = .decimal
        }
        itemsAmountValueLabel.text = (formatter.string(from: NSNumber(value: itemsAmount)) ?? "-") + "원"
        deliveryFeeValueLabel.text = (formatter.string(from: NSNumber(value: deliveryFee)) ?? "-") + "원"
        totalAmountValueLabel.text = (formatter.string(from: NSNumber(value: totalAmount)) ?? "-") + "원"
        finalPaymentAmountValueLabel.text = (formatter.string(from: NSNumber(value: finalPaymentAmount)) ?? "-") + "원"
        if deliveryFee == 0 {
            [deliveryFeeLabel, deliveryFeeValueLabel].forEach {
                $0.isHidden = true
                $0.snp.updateConstraints {
                    $0.height.equalTo(0)
                }
            }
        }
    }
}

extension OrderCartAmountCell {
    
    private func setUpLabels() {
        [totalAmountLabel, totalAmountValueLabel].forEach {
            $0.textColor = .appColor(.neutral800)
            $0.font = .appFont(.pretendardSemiBold, size: 15)
            $0.contentMode = .center
            
        }
        [itemsAmountLabel, itemsAmountValueLabel, deliveryFeeLabel, deliveryFeeValueLabel].forEach {
            $0.textColor = .appColor(.neutral500)
            $0.font = .appFont(.pretendardRegular, size: 13)
            $0.contentMode = .center
        }
        [finalPaymentAmountLabel, finalPaymentAmountValueLabel].forEach {
            $0.textColor = .appColor(.neutral800)
            $0.font = .appFont(.pretendardSemiBold, size: 16)
            $0.contentMode = .center
        }
    }
    
    private func setUpLayout() {
        [totalAmountLabel, totalAmountValueLabel, itemsAmountLabel, itemsAmountValueLabel, deliveryFeeLabel, deliveryFeeValueLabel, finalPaymentAmountLabel, finalPaymentAmountValueLabel, separatorView].forEach {
            insetBackgroundView.addSubview($0)
        }
        [insetBackgroundView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        insetBackgroundView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        totalAmountLabel.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.top.leading.equalToSuperview().inset(24)
        }
        totalAmountValueLabel.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.top.trailing.equalToSuperview().inset(24)
        }
        itemsAmountLabel.snp.makeConstraints {
            $0.height.equalTo(21)
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(totalAmountLabel.snp.bottom).offset(6)
        }
        itemsAmountValueLabel.snp.makeConstraints {
            $0.height.equalTo(21)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(itemsAmountLabel)
        }
        deliveryFeeLabel.snp.makeConstraints {
            $0.height.equalTo(21)
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(itemsAmountLabel.snp.bottom)
        }
        deliveryFeeValueLabel.snp.makeConstraints {
            $0.height.equalTo(21)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(itemsAmountValueLabel.snp.bottom)
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(deliveryFeeLabel.snp.bottom).offset(12)
        }
        finalPaymentAmountLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.top.equalTo(separatorView.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-19)
        }
        finalPaymentAmountValueLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.bottom.equalTo(finalPaymentAmountLabel)
        }
    }
    
    private func configureView() {
        backgroundView = nil
        backgroundColor = .clear
        setUpLabels()
        setUpLayout()
        setUpConstraints()
    }
}
