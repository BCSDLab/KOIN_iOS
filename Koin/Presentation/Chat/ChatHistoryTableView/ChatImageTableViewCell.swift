//
//  ChatImageTableViewCell.swift
//  koin
//
//  Created by 김나훈 on 2/20/25.
//

import Combine
import UIKit

final class ChatImageTableViewCell: UITableViewCell {
    // MARK: - UI Components
    
    private let textImageView = UIImageView().then { _ in
        
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
        textImageView.loadImageWithSpinner(from: message.content)
        
        setUpConstraints(message: message)
    }

}

extension ChatImageTableViewCell {
    private func setUpLayouts() {
        [textImageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints(message: ChatMessage) {
        textImageView.snp.remakeConstraints {
            if message.isMine {
                $0.trailing.equalToSuperview().offset(-16)
            } else {
                $0.leading.equalToSuperview().offset(16)
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
