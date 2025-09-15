//
//  ShopDetailMenuGroupTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/9/25.
//

import UIKit
import SnapKit

final class ShopDetailMenuGroupTableViewCell: UITableViewCell {
    
    // MARK: - Components
    private let labelsStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
    }
    private let nameStackView = UIStackView().then {
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
    
    private let priceStackViews = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .leading
        $0.distribution = .fill
    }
    private var priceNameLabels: [UILabel] = []
    private var priceValueLabels: [UILabel] = []
    
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
        
        priceNameLabels = []
        priceValueLabels = []
        for index in 0..<prices.count {
            priceNameLabels.append(UILabel())
            if let name = prices[index].name {
                priceNameLabels[index].text = "\(name) : "
                priceNameLabels[index].isHidden = false
            }
            else {
                priceNameLabels[index].isHidden = true
            }
            
            priceValueLabels.append(UILabel())
            let formatter = NumberFormatter().then {
                $0.numberStyle = .decimal
            }
            let price = formatter.string(from: NSNumber(value: prices[index].price)) ?? ""
            priceValueLabels[index].text = "\(price)원"
        }
        setUpLabels()
        setUpStackViews()
        
        if let url = thumbnailImage {
            thumbnailImageView.loadImageWithSpinner(from: url)
        }
        else {
            thumbnailImageView.image = nil
        }
        
        if isFirstRow && !isLastRow {
            setTopCornerRadius()
        } else if isLastRow && !isFirstRow {
            setBottomCornerRadius()
        } else if isFirstRow && isLastRow {
            setAllCornerRadius()
        } else {
            setDefaultBackgroundView()
        }
        
        if isLastRow {
            separatorView.isHidden = true
        } else {
            separatorView.isHidden = false
        }
        
        if !isSoldOut {
            [soldOutDimView, soldOutImageView, soldOutLabel].forEach { $0.isHidden = true }
        }
        else {
            [soldOutDimView, soldOutImageView, soldOutLabel].forEach { $0.isHidden = false }
        }
    }
    
    // MARK: - cornerRadius
    private func setTopCornerRadius() {
        backgroundView = UIView().then {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.frame = bounds
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
    private func setBottomCornerRadius() {
        backgroundView = UIView().then {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            $0.frame = bounds
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
        setUpShadow()
    }
    private func setDefaultBackgroundView() {
        backgroundView = UIView().then {
            $0.backgroundColor = .appColor(.neutral0)
            $0.frame = bounds
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
    private func setAllCornerRadius() {
        backgroundView = UIView().then {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.frame = bounds
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
        setUpShadow()
    }
    private func setUpLabels() {
        priceNameLabels.forEach {
            $0.numberOfLines = 0
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.contentMode = .center
            $0.textAlignment = .left
            
            let label = $0
            $0.snp.makeConstraints {
                $0.height.equalTo(22)
                $0.width.equalTo(label.intrinsicContentSize.width)
            }
        }
        priceValueLabels.forEach {
            $0.numberOfLines = 0
            $0.font = .appFont(.pretendardBold, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.contentMode = .center
            $0.textAlignment = .left
            
            let label = $0
            $0.snp.makeConstraints {
                $0.height.equalTo(22)
                $0.width.equalTo(label.intrinsicContentSize.width)
            }
        }
    }
    private func setUpStackViews() {
        [nameLabel, descriptionLabel].forEach {
            nameStackView.addArrangedSubview($0)
        }
        for i in 0..<priceValueLabels.count {
            priceStackViews.addArrangedSubview(UIStackView().then {
                $0.alignment = .fill
                $0.addArrangedSubview(priceNameLabels[i])
                $0.addArrangedSubview(priceValueLabels[i])
            })
        }
        
        [nameStackView, priceStackViews].forEach {
            labelsStackView.addArrangedSubview($0)
        }
        
        priceStackViews.arrangedSubviews.forEach {
            guard let stackView = $0 as? UIStackView else {
                fatalError()
            }
            stackView.axis = .horizontal
            stackView.spacing = 0
            stackView.alignment = .fill
            stackView.distribution = .fill
        }
    }
}

extension ShopDetailMenuGroupTableViewCell {
    
    private func setUpShadow() {
        layer.masksToBounds = false
        layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
    }
    
    private func setUpLayout() {
        [labelsStackView, thumbnailImageView, separatorView].forEach {
            addSubview($0)
        }
        [soldOutDimView, soldOutImageView, soldOutLabel].forEach {
            thumbnailImageView.addSubview($0)
        }
    }
    
    private func setUpConstaints() {
        nameLabel.snp.makeConstraints {
            $0.height.equalTo(29)
        }
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
        }
        
        labelsStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
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
        setUpStackViews()
        setUpLayout()
        setUpConstaints()
    }
}
