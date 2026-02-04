//
//  ChatImageTableViewCell.swift
//  koin
//
//  Created by 김나훈 on 2/20/25.
//

import Combine
import UIKit

final class ChatImageTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    private var imageUrl: String?
    
    // MARK: - UI Components
    let imageTapPublisher = PassthroughSubject<String, Never>()
    var cancellables = Set<AnyCancellable>()
    
    private let textImageView = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.contentMode = .scaleAspectFill
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        textImageView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configure(message: ChatMessage) {
        imageUrl = message.content
        textImageView.loadImageWithSpinner(from: message.content)
        timestampLabel.text = String(format: "%02d:%02d", message.chatDateInfo.hour, message.chatDateInfo.minute)
        setUpConstraints(message: message)
    }
    @objc private func imageTapped() {
        guard let imageUrl else { return }
        imageTapPublisher.send(imageUrl)
    }
    
    override func prepareForReuse() {
        textImageView.image = nil
        cancellables.removeAll()
    }
}

extension ChatImageTableViewCell {
    private func setUpLayouts() {
        [textImageView, timestampLabel].forEach {
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
            $0.width.equalTo(168)
            $0.height.equalTo(168)
            $0.top.bottom.equalToSuperview()
        }
        timestampLabel.snp.remakeConstraints {
            if message.isMine {
                $0.trailing.equalTo(textImageView.snp.leading).offset(-8) // ⏰ 메시지 왼쪽 배치
            } else {
                $0.leading.equalTo(textImageView.snp.trailing).offset(8) // ⏰ 메시지 오른쪽 배치
            }
            $0.bottom.equalTo(textImageView.snp.bottom) // 메시지 하단 정렬
            $0.height.equalTo(19)
        }
    }
    private func configureView() {
        setUpLayouts()
    }
}
