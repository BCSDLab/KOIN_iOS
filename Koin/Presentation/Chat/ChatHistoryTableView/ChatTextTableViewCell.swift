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
        
        setUpConstraints(message: message)
    }
    
}

extension ChatTextTableViewCell {
    private func setUpLayouts() {
        [messageLabel].forEach {
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
   
    }
    private func configureView() {
        setUpLayouts()
    }
}
