//
//  ShopDetailCustomButton.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit

final class ShopDetailCustomButton: UIButton {
    
    // MARK: - Components
    private let minimumOrderLabel = UILabel().then {
        $0.text = "최소주문"
        $0.numberOfLines = 0
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.contentMode = .center
    }
    private let deliveryTipLabel = UILabel().then {
        $0.text = "배달금액"
        $0.numberOfLines = 0
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.contentMode = .center
    }
    private let introductionLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    private let minimumOrderSubLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .left
    }
    private let deliveryTipSubLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .left
    }
    private let inorderableLabel = UILabel().then {
        $0.setLineHeight(lineHeight: 1.60, text: "코인 주문이\n불가능한 매장이예요.")
        $0.numberOfLines = 0
        $0.font = .appFont(.pretendardSemiBold, size: 12)
        $0.textColor = .appColor(.neutral400)
        $0.textAlignment = .center
    }
    
    private let leftImageView = UIImageView(image: UIImage.appImage(asset: .speaker))
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

    func configure(minOrderAmount: Int?, minDeliveryTip: Int?, maxDelieveryTip: Int?, introduction: String?, inorderable: Bool) {
        
        if inorderable {
            configureInorderableLabel()
        }
        else if let minOrderAmount, let minDeliveryTip, let maxDelieveryTip {
            minimumOrderSubLabel.text = "\(minOrderAmount.formattedWithComma)원"
            deliveryTipSubLabel.text = "\(minDeliveryTip.formattedWithComma) - \(maxDelieveryTip.formattedWithComma)원"
            configureOrderAmountDelieveryTipView()
        }
        else {
            introductionLabel.setLineHeight(lineHeight: 1.6, text: introduction ?? "공지사항")
            configureIntroductionView()
        }
    }
}

extension ShopDetailCustomButton {
    
    private func configureInorderableLabel() {
        [inorderableLabel].forEach {
            addSubview($0)
        }
        inorderableLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-4)
        }
    }

    private func configureOrderAmountDelieveryTipView() {
        [minimumOrderLabel, minimumOrderSubLabel, deliveryTipLabel, deliveryTipSubLabel, rightImageView].forEach {
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
        rightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
    
    private func configureIntroductionView() {
        [leftImageView, introductionLabel, rightImageView].forEach {
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
        rightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
    
    private func configureView() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 12
    }
}
