//
//  NotificationTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import UIKit
import SnapKit
import Then

final class NotificationTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let dateLabel = UILabel()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(item: NotificationItem) {
        iconImageView.image = .appImage(asset: item.icon)?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = item.title
        contentLabel.text = item.content
        dateLabel.text = item.dateText
        
        iconImageView.tintColor = item.isRead ? .appColor(.neutral500) : .appColor(.new500)
        titleLabel.textColor = item.isRead ? .appColor(.neutral500) : .appColor(.neutral800)
    }
}

// MARK: - Configure
extension NotificationTableViewCell {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        selectionStyle = .none
        
        iconImageView.do {
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 13)
            $0.numberOfLines = 1
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        dateLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 10)
            $0.textColor = UIColor.ColorSystem.Neutral.gray500
            $0.numberOfLines = 1
        }
        
        contentLabel.do {
            $0.font = UIFont.appFont(.pretendardMedium, size: 12)
            $0.textColor = .appColor(.neutral500)
            $0.numberOfLines = 1
        }
    }
    
    private func setUpLayouts() {
        [iconImageView, titleLabel, contentLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(8 + 10)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(21)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(20)
            $0.trailing.lessThanOrEqualTo(dateLabel.snp.leading).offset(-16)
            $0.top.equalToSuperview().offset(8 + 10)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        contentLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(dateLabel)
            $0.bottom.equalToSuperview().offset(-(8 + 10)).priority(.high)
        }
    }
}
