//
//  CallVanNotificationTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import UIKit
import SnapKit
import Then

final class CallVanNotificationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    // MARK: - UI Components
    private let isReadDot = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let peopleImageView = UIImageView()
    private let participantsLabel = UILabel()
    private let messagePreviewLabel = UILabel()
    private let separatorView = UIView()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(notification: CallVanNotification, shouldHideSeparator: Bool) {
        
        isReadDot.isHidden = notification.isRead
        
        titleLabel.do {
            $0.text = notification.title
            $0.textColor = notification.titleTextColor
        }
        
        descriptionLabel.do {
            $0.text = notification.description
            $0.textColor = notification.descriptionTextColor
        }
        
        peopleImageView.do {
            $0.tintColor = notification.descriptionTextColor
        }
        
        participantsLabel.do {
            $0.text = "\(notification.currentParticipants)/\(notification.maxParticipants)"
            $0.textColor = notification.descriptionTextColor
        }
        
        messagePreviewLabel.do {
            $0.text = notification.messagePreview
            $0.textColor = notification.messagePreviewTextColor
        }
        
        separatorView.isHidden = shouldHideSeparator
    }
}

extension CallVanNotificationTableViewCell {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        isReadDot.do {
            $0.backgroundColor = UIColor.appColor(.new500)
            $0.layer.cornerRadius = 4
        }

        titleLabel.do {
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        }
        
        descriptionLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 10)
        }
        
        peopleImageView.do {
            $0.image = UIImage.appImage(asset: .callVanListPeople)?.withRenderingMode(.alwaysTemplate)
        }
        
        participantsLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 10)
        }
        
        messagePreviewLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 10)
        }
        
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral200)
        }
    }
    
    private func setUpLayouts() {
        [isReadDot, titleLabel, descriptionLabel, peopleImageView, participantsLabel, messagePreviewLabel, separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        isReadDot.snp.makeConstraints {
            $0.size.equalTo(8)
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(28)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(56)
        }
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalTo(titleLabel)
        }
        peopleImageView.snp.makeConstraints {
            $0.size.equalTo(15)
            $0.centerY.equalTo(descriptionLabel)
            $0.leading.equalTo(descriptionLabel.snp.trailing).offset(4)
        }
        participantsLabel.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.top.equalTo(descriptionLabel)
            $0.leading.equalTo(peopleImageView.snp.trailing).offset(2)
        }
        
        messagePreviewLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(descriptionLabel.snp.bottom)
            $0.leading.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-12).priority(999)
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
    }
}
