//
//  ShopSummaryCustomButton.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit

final class ShopSummaryDeliveryButton: UIButton {
    
    // MARK: - UI Components
    private let minimumOrderLabel = UILabel().then {
        $0.text = "최소주문"
        $0.numberOfLines = 1
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.contentMode = .center
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    private let deliveryTipLabel = UILabel().then {
        $0.text = "배달금액"
        $0.numberOfLines = 1
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.contentMode = .center
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    private let minimumOrderSubLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .left
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    private let deliveryTipSubLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .left
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    private let inorderableLabel = UILabel().then {
        $0.setLineHeight(lineHeight: 1.60, text: "코인 주문이\n불가능한 매장이예요.")
        $0.numberOfLines = 2
        $0.font = .appFont(.pretendardSemiBold, size: 12)
        $0.textColor = .appColor(.neutral400)
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private let rightImageView = UIImageView(image: UIImage.appImage(asset: .newChevronRight)?.withRenderingMode(.alwaysTemplate)).then {
        $0.tintColor = .appColor(.neutral500)
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(minOrderAmount: Int, minDeliveryTip: Int, maxDelieveryTip: Int) {
        
        minimumOrderSubLabel.text = "\(minOrderAmount.formattedWithComma)원"
        
        if minDeliveryTip == 0, maxDelieveryTip == 0 {
            deliveryTipSubLabel.text = "0원"
        }
        else {
            deliveryTipSubLabel.text = "\(minDeliveryTip.formattedWithComma) - \(maxDelieveryTip.formattedWithComma)원"
        }
    }
}

extension ShopSummaryDeliveryButton {
    
    private func setUpIsHidden() {
        [minimumOrderLabel, minimumOrderSubLabel, deliveryTipLabel, deliveryTipSubLabel, rightImageView].forEach {
            $0.isHidden = true
        }
        inorderableLabel.isHidden = false
    }
    
    private func setUpLayout() {
        [minimumOrderLabel, minimumOrderSubLabel, deliveryTipLabel, deliveryTipSubLabel, rightImageView, inorderableLabel].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        minimumOrderLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(8)
            $0.height.equalTo(19)
        }
        deliveryTipLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.equalTo(19)
        }
        minimumOrderSubLabel.snp.makeConstraints {
            $0.leading.equalTo(minimumOrderLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualTo(rightImageView.snp.leading).offset(-7)
            $0.centerY.equalTo(minimumOrderLabel)
        }
        deliveryTipSubLabel.snp.makeConstraints {
            $0.leading.equalTo(deliveryTipLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualTo(rightImageView.snp.leading).offset(-7)
            $0.centerY.equalTo(deliveryTipLabel)
        }
        rightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        inorderableLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-4)
        }
    }
    
    private func configureView() {
        setUpLayout()
        setUpConstraints()
        
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 12
    }
}
