//
//  LandListTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import SnapKit

final class LandListTableViewCell: UITableViewCell {

    // MARK: - UI Components
    private let nameLabel = UILabel()
    private let roomTypeLabel = UILabel()
    private let addressLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let monthlyBadge = LandListBadgeView(style: .monthly)
    private let charterBadge = LandListBadgeView(style: .charter)
    private let badgeStackView = UIStackView()
    private let separatorView = UIView()
    private let titleStackView = UIStackView()
    private let addressStackView = UIStackView()
    private let infoStackView = UIStackView()
    private let contentStackView = UIStackView()

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandListTableViewCell {
    func configure(row: LandRow) {
        nameLabel.text = row.name
        roomTypeLabel.text = row.roomType
        addressLabel.text = row.address
        monthlyBadge.isHidden = !row.isMonthlyAvailable
        charterBadge.isHidden = !row.isCharterAvailable
        badgeStackView.isHidden = !row.isMonthlyAvailable && !row.isCharterAvailable
    }
}

extension LandListTableViewCell {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        selectionStyle = .none
        nameLabel.do {
            $0.font = .appFont(.pretendardSemiBold, size: 16)
            $0.textColor = UIColor.ColorSystem.Neutral.gray800
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        roomTypeLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 10)
            $0.textColor = UIColor.ColorSystem.Neutral.gray600
        }
        addressLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.ColorSystem.Neutral.gray600
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        chevronImageView.do {
            $0.image = UIImage.appImage(asset: .chevronRightHome)?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = UIColor.ColorSystem.Neutral.gray600
        }
        separatorView.backgroundColor = .appColor(.neutral100)
        titleStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
        addressStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
        }
        badgeStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }
        infoStackView.do {
            $0.axis = .vertical
            $0.spacing = 4
            $0.alignment = .leading
        }
        contentStackView.do {
            $0.axis = .vertical
            $0.spacing = 8
            $0.alignment = .leading
        }
    }
    
    private func setUpLayouts() {
        [nameLabel, roomTypeLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [addressLabel, chevronImageView].forEach {
            addressStackView.addArrangedSubview($0)
        }
        [monthlyBadge, charterBadge].forEach {
            badgeStackView.addArrangedSubview($0)
        }
        [titleStackView, addressStackView].forEach {
            infoStackView.addArrangedSubview($0)
        }
        [infoStackView, badgeStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        [separatorView, contentStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        separatorView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-8)
        }
        infoStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        titleStackView.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.width.lessThanOrEqualToSuperview()
        }
        addressStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        chevronImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
    }
}
