//
//  DeliveryTipsCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit

final class DeliveryTipsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Components
    private let label = UILabel().then {
        $0.textAlignment = .left
        $0.numberOfLines = 1
        $0.font = .appFont(.pretendardMedium, size: 12)
        $0.textColor = .appColor(.neutral800)
    }
    private let topBorderView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    private let leadingBorderView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(fromAmount: Int, toAmount: Int?) {
        let formatter = NumberFormatter().then {
            $0.numberStyle = .decimal
        }
        if let toAmount = toAmount,
           let fromAmount = formatter.string(from: NSNumber(value: fromAmount)),
           let toAmount = formatter.string(from: NSNumber(value: toAmount)) {
            label.text = "\(fromAmount) ~ \(toAmount)원 미만"
        }
        else if let fromAmount = formatter.string(from: NSNumber(value: fromAmount)) {
            label.text = "\(fromAmount)원 이상"
        }
    }
    func configure(fee: Int) {
        let formatter = NumberFormatter().then {
            $0.numberStyle = .decimal
        }
        if let fee = formatter.string(from: NSNumber(value: fee)) {
            label.text = "\(fee)원"
        }
    }
}

extension DeliveryTipsCollectionViewCell {
    
    private func configureView() {
        [label, topBorderView, leadingBorderView].forEach {
            contentView.addSubview($0)
        }
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        topBorderView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(1)
        }
        leadingBorderView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(1)
        }
    }
}
