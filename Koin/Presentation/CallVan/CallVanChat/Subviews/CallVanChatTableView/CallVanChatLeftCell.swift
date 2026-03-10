//
//  CallVanChatLeftCell.swift
//  koin
//
//  Created by 홍기정 on 3/9/26.
//

import UIKit
import SnapKit
import Then

final class CallVanChatLeftCell: UITableViewCell {
    
    // MARK: - Properties
    private let messageTextLabelAttributes: [NSAttributedString.Key : Any] = {
        let font = UIFont.appFont(.pretendardRegular, size: 12)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = font.lineHeight * 0.6
        return [
            .font : font,
            .paragraphStyle : paragraph,
            .foregroundColor : UIColor.appColor(.neutral800)
        ]
    }()
    
    // MARK: - UI Components
    private let contentsStackView = UIStackView()
    
    private let profileWrapperView = UIView()
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let leftUserLabel = UILabel()
    
    private let messageImageWrapperView = UIView()
    private let messageImageView = UIImageView()
    private let messageImageTimeLabel = UILabel()
    
    private let messageTextWrapperView = UIView()
    private let messageTextView = UIView()
    private let messageTextLabel = UILabel()
    private let messageTextTimeLabel = UILabel()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(message: CallVanChatMessage) {
        
        // MARK: 프로필
        profileWrapperView.isHidden = !message.showProfile
        profileImageView.image = message.profileImage
        nicknameLabel.text = message.senderNickname
        leftUserLabel.isHidden = !message.isLeftUser
        
        // MARK: 이미지
        messageImageWrapperView.isHidden = !message.isImage
        if message.isImage {
            messageImageView.loadImageWithSpinner(from: message.content)
            messageImageTimeLabel.text = message.time
        }
        
        // MARK: 텍스트
        messageTextWrapperView.isHidden = message.isImage
        if !message.isImage {
            messageTextLabel.attributedText = NSAttributedString(
                string: message.content,
                attributes: messageTextLabelAttributes
            )
            messageTextTimeLabel.text = message.time
        }
    }
}

extension CallVanChatLeftCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        messageImageView.image = nil
    }
}

extension CallVanChatLeftCell {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        contentsStackView.do {
            $0.axis = .vertical
            $0.spacing = 8
            $0.alignment = .leading
            $0.distribution = .fillProportionally
        }
        
        // MARK: 닉네임
        nicknameLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral600)
        }
        leftUserLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 10)
            $0.textColor = UIColor.appColor(.new500)
            $0.text = "(나간 사용자)"
        }
        
        // MARK: 이미지
        messageImageView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
        }
        messageImageTimeLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
        
        // MARK: 텍스트
        messageTextView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 8
        }
        messageTextLabel.do {
            $0.numberOfLines = 0
        }
        messageTextTimeLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
    }
    
    private func setUpLayouts() {
        [profileImageView, nicknameLabel, leftUserLabel].forEach {
            profileWrapperView.addSubview($0)
        }
        [messageImageView, messageImageTimeLabel].forEach {
            messageImageWrapperView.addSubview($0)
        }
        [messageTextView, messageTextLabel, messageTextTimeLabel].forEach {
            messageTextWrapperView.addSubview($0)
        }
        [profileWrapperView, messageImageWrapperView, messageTextWrapperView].forEach {
            contentsStackView.addArrangedSubview($0)
        }
        [contentsStackView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentsStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8).priority(999)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        // MARK: 프로필
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(profileWrapperView).offset(8)
            $0.leading.bottom.equalTo(profileWrapperView)
            $0.size.equalTo(32)
        }
        nicknameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }
        leftUserLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(nicknameLabel.snp.trailing).offset(4)
        }
        
        // MARK: 이미지
        messageImageView.snp.makeConstraints {
            $0.size.equalTo(168)
            $0.top.leading.bottom.equalTo(messageImageWrapperView)
        }
        messageImageTimeLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.leading.equalTo(messageImageView.snp.trailing).offset(8)
            $0.bottom.trailing.equalTo(messageImageWrapperView)
        }
        
        // MARK: 텍스트
        messageTextView.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(messageTextWrapperView)
        }
        messageTextLabel.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(UIScreen.main.bounds.width / 2)
            $0.top.bottom.equalTo(messageTextView).inset(8)
            $0.leading.trailing.equalTo(messageTextView).inset(12)
        }
        messageTextTimeLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.leading.equalTo(messageTextView.snp.trailing).offset(8)
            $0.bottom.trailing.equalTo(messageTextWrapperView)
        }
    }
}
