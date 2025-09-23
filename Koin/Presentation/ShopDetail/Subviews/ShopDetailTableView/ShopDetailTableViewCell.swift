//
//  ShopDetailTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/9/25.
//

import UIKit
import SnapKit

final class ShopDetailTableViewCell: UITableViewCell {
    
    // MARK: - Components
    private var insetBackgroundView = UIView().then { $0.backgroundColor = .yellow }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 0
    }
    
    private let nameLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.contentMode = .center
        $0.textAlignment = .left
    }
    private let descriptionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.contentMode = .center
        $0.textAlignment = .left
    }
    private let paddingView = UIView().then { $0.backgroundColor = .red }
    private let priceTableView = ShopDetailPriceTableView(frame: .zero, style: .plain).then {
        $0.isScrollEnabled = false
        $0.sectionHeaderTopPadding = 0
        $0.separatorStyle = .none
        $0.rowHeight = 22
    }

    private let thumbnailImageView = UIImageView().then {
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    private let soldOutDimView = UIView().then {
        $0.backgroundColor = .appColor(.neutral800)
        $0.layer.opacity = 0.6
    }
    private let soldOutImageView = UIImageView(image: .appImage(asset: .noMeal))
    private let soldOutLabel = UILabel().then {
        $0.text = "품절"
        $0.textAlignment = .center
        $0.font = .appFont(.pretendardSemiBold, size: 14)
        $0.textColor = .appColor(.neutral0)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(name: String, description: String?, prices: [Price],
                   thumbnailImage: String?, isFirstRow: Bool, isLastRow: Bool, isSoldOut: Bool) {
        
        nameLabel.text = name
        
        if description != nil && description != "" {
            descriptionLabel.text = description
            descriptionLabel.isHidden = false
        }
        else {
            descriptionLabel.isHidden = true
        }
        
        priceTableView.configure(prices: prices)
        priceTableView.snp.updateConstraints {
            $0.height.equalTo(prices.count * 22)
        }
        
        if let url = thumbnailImage {
            thumbnailImageView.loadImageWithSpinner(from: url)
        } else {
            thumbnailImageView.image = nil
        }
        
        setCornerRadius(isFirstRow: isFirstRow, isLastRow: isLastRow)
        setShadow(isLastRow: isLastRow)
        separatorView.isHidden = isLastRow
        [soldOutDimView, soldOutImageView, soldOutLabel].forEach {
            $0.isHidden = !isSoldOut
        }
    }
    
    // MARK: - cornerRadius
    private func setCornerRadius(isFirstRow: Bool, isLastRow: Bool){
        [insetBackgroundView].forEach {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.frame = bounds
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
        switch (isFirstRow, isLastRow) {
        case (true, true): // 첫번쨰&&마지막 row (단일 row)
            insetBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                                       .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case (true, false): // 첫번째 row
            insetBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case (false, true): // 마지막 row
            insetBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case (false, false): // 중간 row
            insetBackgroundView.layer.cornerRadius = 0
        }
    }
    
    private func setShadow(isLastRow: Bool) {
        switch isLastRow {
        case true:
            insetBackgroundView.layer.masksToBounds = false
            insetBackgroundView.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        case false:
            insetBackgroundView.layer.masksToBounds = true
            insetBackgroundView.layer.applySketchShadow(color: .clear, alpha: 0.0, x: 0, y: 0, blur: 0, spread: 0)
        }
    }
}

extension ShopDetailTableViewCell {

    private func setUpLayout() {
        [insetBackgroundView].forEach {
            contentView.addSubview($0)
        }
        [stackView, thumbnailImageView, separatorView].forEach {
            insetBackgroundView.addSubview($0)
        }
        [nameLabel, descriptionLabel, paddingView, priceTableView].forEach {
            stackView.addArrangedSubview($0)
        }
        [soldOutDimView, soldOutImageView, soldOutLabel].forEach {
            thumbnailImageView.addSubview($0)
        }
    }
    
    private func setUpConstaints() {
        insetBackgroundView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        nameLabel.snp.makeConstraints {
            $0.height.equalTo(29)
        }
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
        }
        paddingView.snp.makeConstraints {
            $0.height.equalTo(4)
        }
        priceTableView.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(thumbnailImageView.snp.leading).offset(-12)
            $0.top.greaterThanOrEqualToSuperview().offset(12)
            $0.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        thumbnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(88)
            $0.trailing.bottom.equalToSuperview().offset(-12)
            $0.top.greaterThanOrEqualToSuperview().offset(12)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        soldOutDimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        soldOutImageView.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
        }
        soldOutLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(soldOutImageView)
            $0.top.equalTo(soldOutImageView.snp.bottom)
            $0.height.equalTo(24)
        }
    }
    private func configureView() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        setUpLayout()
        setUpConstaints()
        backgroundView = nil
    }
}
