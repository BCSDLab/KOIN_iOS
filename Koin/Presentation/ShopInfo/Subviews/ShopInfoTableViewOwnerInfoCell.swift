//
//  ShopInfoTableViewOwnerInfoCell.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit

final class ShopInfoTableViewOwnerInfoCell: UITableViewCell {
    
    // MARK: - Components
    private let titleLabel = UILabel().then {
        $0.contentMode = .center
        $0.font = .appFont(.pretendardSemiBold, size: 15)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .leading
    }
    private let nameTitleLabel = UILabel().then { $0.text = "대표자명" }
    private let shopNameTitleLabel = UILabel().then { $0.text = "상호명" }
    private let addressTitleLabel = UILabel().then { $0.text = "사업자 주소" }
    private let companyRegistrationNumberTitleLabel = UILabel().then { $0.text = "사업자 등록 번호" }
    
    private let valueStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .leading
    }
    private let nameValueLabel = UILabel()
    private let shopNameValueLabel = UILabel()
    private let addressValueLabel = UILabel()
    private let companyRegistrationNumberValueLabel = UILabel()
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral50)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, ownerInfo: OwnerInfo) {
        titleLabel.text = title
        nameValueLabel.text = ownerInfo.name
        shopNameValueLabel.text = ownerInfo.shopName
        addressValueLabel.text = ownerInfo.address
        companyRegistrationNumberValueLabel.text = ownerInfo.companyRegistrationNumber
    }
}

extension ShopInfoTableViewOwnerInfoCell {
    
    private func setUpLabels() {
        [nameTitleLabel, shopNameTitleLabel, addressTitleLabel, companyRegistrationNumberTitleLabel,
         nameValueLabel, shopNameValueLabel, addressValueLabel, companyRegistrationNumberValueLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.textAlignment = .left
            $0.numberOfLines = 1
        }
    }
    private func setUpLayout() {
        [nameTitleLabel, shopNameTitleLabel, addressTitleLabel, companyRegistrationNumberTitleLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [nameValueLabel, shopNameValueLabel, addressValueLabel, companyRegistrationNumberValueLabel].forEach {
             valueStackView.addArrangedSubview($0)
        }
        [titleLabel, titleStackView, valueStackView, separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(companyRegistrationNumberTitleLabel.intrinsicContentSize.width)
            $0.bottom.equalToSuperview().offset(-18)
        }
        valueStackView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.top)
            $0.leading.equalTo(titleStackView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-22)
            $0.bottom.equalTo(titleStackView.snp.bottom)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(6)
        }
    }
    private func configureView() {
        setUpLabels()
        setUpLayout()
        setUpConstraints()
    }
}
