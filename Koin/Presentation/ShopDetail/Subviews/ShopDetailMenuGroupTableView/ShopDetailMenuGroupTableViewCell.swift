//
//  ShopDetailMenuGroupTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/9/25.
//

import UIKit
import SnapKit

class ShopDetailMenuGroupTableViewCell: UITableViewCell {
    
    // MARK: - Components
    let labelsStackView = UIStackView()
    let nameDescriptionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 0
    }
    let nameLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.contentMode = .center
        $0.textAlignment = .left
    }
    let descriptionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.contentMode = .center
        $0.textAlignment = .left
    }
    let priceStackViews = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .leading
        $0.distribution = .fill
    }
    var priceNameLabels: [UILabel] = []
    var priceValueLabels: [UILabel] = []
    
    let thumbnailImageView = UIImageView().then {
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    func bind(name: String, description: String?, prices: [Price], thumbnailImage: String?, isFirstRow: Bool, isLastRow: Bool) {
        nameLabel.text = name
        
        if let description { descriptionLabel.text = description }
        else { descriptionLabel.text = nil }
        
        prices.forEach { price in
            priceNameLabels.append(UILabel().then {
                if let name = price.name { $0.text = "\(name) : " }
                else { $0.text = nil }
            })
            priceValueLabels.append(UILabel().then {
                $0.text = "\(price.price)원"
            })
        }
        
        if let url = thumbnailImage {
            thumbnailImageView.loadImageWithSpinner(from: url)
        }
        else {
            thumbnailImageView.image = nil
        }
        
        //DispatchQueue.main.async { [weak self] in
            self.configureView()
        //}
        
        if (isFirstRow && !isLastRow) {
            setTopCornerRadius()
        } else if (isLastRow && !isFirstRow) {
            setBottomCornerRadius()
        } else if (isFirstRow && isLastRow) {
            setCornerRadius()
        }
        if (isLastRow) {
            separatorView.isHidden = true
        } else {
            separatorView.isHidden = false
        }
    }
}

extension ShopDetailMenuGroupTableViewCell {
    
    // MARK: - cornerRadius
    private func setTopCornerRadius() {
        let bgView = UIView().then {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.frame = bounds
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
        backgroundView = bgView
    }
    private func setBottomCornerRadius() {
        let bgView = UIView().then {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            $0.frame = bounds
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
        backgroundView = bgView
    }
    private func setCornerRadius() {
        let bgView = UIView().then {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.frame = bounds
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
        backgroundView = bgView
    }
}
extension ShopDetailMenuGroupTableViewCell {
    
    private func setUpLayout() {
        [labelsStackView, thumbnailImageView, separatorView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstaints() {
        nameLabel.snp.makeConstraints {
            $0.height.equalTo(29)
        }
        descriptionLabel.snp.makeConstraints {
            if descriptionLabel.text != nil {
                $0.height.equalTo(19)
            }
            else {
                $0.height.equalTo(0)
            }
        }
        priceStackViews.arrangedSubviews.forEach {
            guard let stackView = $0 as? UIStackView else {
                fatalError()
            }
            stackView.snp.makeConstraints {
                $0.height.equalTo(22)
            }
        }
        priceStackViews.arrangedSubviews.forEach {
            guard let stackView = $0 as? UIStackView else { return }
            stackView.arrangedSubviews.forEach {
                let label = $0
                $0.snp.makeConstraints {
                    $0.width.equalTo(label.intrinsicContentSize.width)
                }
            }
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
    }
    
    private func configureLabels() {
        priceNameLabels.forEach {
            $0.numberOfLines = 0
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.contentMode = .center
            $0.textAlignment = .left
        }
        priceValueLabels.forEach {
            $0.numberOfLines = 0
            $0.font = .appFont(.pretendardBold, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.contentMode = .center
            $0.textAlignment = .left
        }
    }
    private func configureStackViews() {
        for i in (0..<priceValueLabels.count) {
            priceStackViews.addArrangedSubview(UIStackView().then {
                $0.alignment = .fill
                $0.addArrangedSubview(priceNameLabels[i].then {
                    if $0.text == nil { $0.isHidden = true }
                    else { $0.isHidden = false }
                })
                $0.addArrangedSubview(priceValueLabels[i])
            })
        }
        nameDescriptionStackView.addArrangedSubview(nameLabel.then {
            if $0.text == nil { $0.isHidden = true }
            else { $0.isHidden = false }
        })
        nameDescriptionStackView.addArrangedSubview(descriptionLabel)
        
        [nameDescriptionStackView, priceStackViews].forEach {
            labelsStackView.addArrangedSubview($0)
        }
        
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .leading
        
        if 1 < priceStackViews.arrangedSubviews.count { labelsStackView.spacing = 4 }
        else { labelsStackView.spacing = 0 }
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
    
    private func configureView() {
        backgroundColor = .clear
        configureStackViews()
        configureLabels()
        setUpLayout()
        setUpConstaints()
    }
}
