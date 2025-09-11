//
//  ShopDetailCustomButton.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit

class ShopDetailCustomButton: UIButton {
    
    // MARK: - Components
    let minimumOrderLabel = UILabel().then {
        $0.text = "최소주문"
        $0.numberOfLines = 0
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.contentMode = .center
    }
    let deliveryTipLabel = UILabel().then {
        $0.text = "배달금액"
        $0.numberOfLines = 0
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.contentMode = .center
    }
    let minimumOrderSubLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .left
    }
    let deliveryTipSubLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .left
    }
    let introductionLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    let leftImageView = UIImageView(image: UIImage.appImage(asset: .speaker))
    let rightImageView = UIImageView(image: UIImage.appImage(asset: .newChevronRight)?.withRenderingMode(.alwaysTemplate)).then {
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
}

extension ShopDetailCustomButton {
    
    // MARK: - bind
    func bind(minOrderAmount: Int? = nil, minDeliveryTip: Int? = nil, maxDelieveryTip: Int? = nil, introduction: String? = nil) {
        
        if let introduction {
            introductionLabel.setLineHeight(lineHeight: 1.6, text: introduction)
            setUpIntroductionView()
        }
        else if let minOrderAmount, let minDeliveryTip, let maxDelieveryTip {
            minimumOrderSubLabel.text = "\(minOrderAmount.formattedWithComma)원"
            deliveryTipSubLabel.text = "\(minDeliveryTip.formattedWithComma) - \(maxDelieveryTip.formattedWithComma)원"
            setUpOrderAmountDelieveryTipView()
        }
    }
    
    // MARK: - configureVuew
    private func setUpOrderAmountDelieveryTipView() {
        [minimumOrderLabel, minimumOrderSubLabel, deliveryTipLabel, deliveryTipSubLabel].forEach {
            addSubview($0)
        }
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
            //$0.trailing.equalTo(rightImageView.snp.leading).offset(-7)
            $0.centerY.equalTo(minimumOrderLabel)
        }
        deliveryTipSubLabel.snp.makeConstraints {
            $0.leading.equalTo(minimumOrderLabel.snp.trailing).offset(8)
            $0.trailing.equalTo(rightImageView.snp.leading).offset(-7)
            $0.centerY.equalTo(deliveryTipLabel)
        }
    }
    
    private func setUpIntroductionView() {
        [leftImageView, introductionLabel].forEach {
            addSubview($0)
        }
        leftImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        introductionLabel.snp.makeConstraints {
            $0.leading.equalTo(leftImageView.snp.trailing).offset(7)
            $0.trailing.equalTo(rightImageView.snp.leading).offset(-7)
            $0.centerY.equalToSuperview().offset(-4)
        }
    }
    
    private func configureView() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 12
        
        [rightImageView].forEach {
            addSubview($0)
        }
        rightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }
    }
}
