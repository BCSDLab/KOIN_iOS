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
    private let secondaryContentLabel = UILabel()
    private lazy var titleContentStackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel, secondaryContentLabel])
    
    private let dateLabel = UILabel()
    private let badgeLabel = PaddingLabel(textInsets: .init(top: 0, left: 4, bottom: 0, right: 4))
    private lazy var dateBadgeStackView = UIStackView(arrangedSubviews: [dateLabel, badgeLabel])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        iconImageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        contentLabel.text = nil
        secondaryContentLabel.text = nil
        badgeLabel.text = nil
        badgeLabel.isHidden = true
        secondaryContentLabel.isHidden = true
    }

    func configure(item: NotificationItem) {
        iconImageView.image = notificationIcon(for: item.iconType)

        titleLabel.text = item.title
        dateLabel.text = item.dateText
        let paragraphStyle = NSMutableParagraphStyle().then {
            $0.minimumLineHeight = 12 * 1.6
            $0.maximumLineHeight = 12 * 1.6
        }
        contentLabel.attributedText = NSAttributedString(
            string: item.content,
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 12),
                .foregroundColor: UIColor.appColor(.neutral500),
                .paragraphStyle: paragraphStyle
            ])

        if item.iconType == .callvanpot, let secondaryContent = item.secondaryContent {
            secondaryContentLabel.text = secondaryContent
            secondaryContentLabel.isHidden = false
            contentLabel.numberOfLines = 1
        } else {
            secondaryContentLabel.isHidden = true
            contentLabel.numberOfLines = 2
        }

        if let badgeText = item.badgeText {
            badgeLabel.text = badgeText
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
    }
}

// MARK: - Configure

private extension NotificationTableViewCell {
    func setUpStyles() {
        selectionStyle = .none
        backgroundColor = UIColor.ColorSystem.Neutral.gray0
        contentView.backgroundColor = UIColor.ColorSystem.Neutral.gray0
        
        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        titleLabel.do {
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 13)
            $0.textColor = UIColor.appColor(.neutral800)
            $0.numberOfLines = 1
        }
        
        dateLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 10)
            $0.textColor = UIColor.appColor(.neutral400)
            $0.numberOfLines = 1
            $0.textAlignment = .right
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        contentLabel.do {
            $0.font = UIFont.appFont(.pretendardMedium, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
        
        secondaryContentLabel.do {
            $0.font = UIFont.appFont(.pretendardMedium, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
            $0.numberOfLines = 1
        }
        
        badgeLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 10)
            $0.textColor = UIColor.appColor(.new500)
            $0.textAlignment = .center
            $0.contentMode = .center
            $0.backgroundColor = UIColor(hexCode: "EBD4FE")
            $0.layer.cornerRadius = 5
            $0.clipsToBounds = true
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        titleContentStackView.do {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.spacing = 4
        }
        
        dateBadgeStackView.do {
            $0.axis = .vertical
            $0.alignment = .trailing
            $0.spacing = 4
        }
    }
    
    func setUpLayouts() {
        [iconImageView, titleContentStackView, dateBadgeStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func setUpConstraints() {
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        titleContentStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(20)
        }
        
        dateBadgeStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalTo(titleContentStackView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(21)
        }
        
        dateLabel.snp.makeConstraints {
            $0.height.equalTo(21)
        }
        
        badgeLabel.snp.makeConstraints {
            $0.height.equalTo(16)
        }
    }

    func notificationIcon(for iconType: NotificationIconType) -> UIImage? {
        switch iconType {
        case .breakfast:
            return UIImage.appImage(asset: .notificationBowl)
        case .board:
            return UIImage.appImage(asset: .notificationNotice)
        case .callvanpot:
            return UIImage.appImage(asset: .notificationCallVan)
        case .shuttleTicket:
            return UIImage.appImage(asset: .notificationBusQR)
        }
    }
}
