//
//  ChatTextTableViewCell.swift
//  koin
//
//  Created by 김나훈 on 2/20/25.
//

import UIKit

final class ChatTextTableViewCell: UITableViewCell {
    // MARK: - UI Components
    
    private let messageLabel = InsetLabel(top: 10, left: 12, bottom: 10, right: 12).then {
        $0.numberOfLines = 0
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.textAlignment = .left
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
        $0.lineBreakMode = .byCharWrapping
    }
    private let timestampLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .center
    }

    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configure(message: ChatMessage) {
        messageLabel.text = message.content
        messageLabel.backgroundColor = message.isMine ? UIColor.appColor(.neutral100) : UIColor.appColor(.info100)
        timestampLabel.text = String(format: "%02d:%02d", message.chatDateInfo.hour, message.chatDateInfo.minute)
        setUpConstraints(message: message)
    }
    
}

extension ChatTextTableViewCell {
    private func setUpLayouts() {
        [messageLabel, timestampLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints(message: ChatMessage) {
        messageLabel.snp.remakeConstraints {
            if message.isMine {
                $0.trailing.equalToSuperview().offset(-16)
                $0.leading.greaterThanOrEqualToSuperview().offset(50)
            } else {
                $0.leading.equalToSuperview().offset(16)
                $0.trailing.lessThanOrEqualToSuperview().offset(-50)
            }
            $0.width.lessThanOrEqualTo(209)
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
        }
        timestampLabel.snp.remakeConstraints {
               if message.isMine {
                   $0.trailing.equalTo(messageLabel.snp.leading).offset(-8) // ⏰ 메시지 왼쪽 배치
               } else {
                   $0.leading.equalTo(messageLabel.snp.trailing).offset(8) // ⏰ 메시지 오른쪽 배치
               }
               $0.bottom.equalTo(messageLabel.snp.bottom) // 메시지 하단 정렬
            $0.height.equalTo(19)
           }
    }
    private func configureView() {
        setUpLayouts()
    }
}
