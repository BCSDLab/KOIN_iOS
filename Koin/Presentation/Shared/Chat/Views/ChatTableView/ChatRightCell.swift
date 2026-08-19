//
//  ChatRightCell.swift
//  koin
//
//  Created by 홍기정 on 3/9/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class ChatRightCell: UITableViewCell {
    
    // MARK: - Properties
    let imageTappedPublisher = PassthroughSubject<String, Never>()
    var subscriptions: Set<AnyCancellable> = []
    private var imageUrl: String?
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
        setGesture()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(message: ChatMessageRowModel) {
        
        // MARK: 프로필
        profileWrapperView.isHidden = !message.showsProfile
        
        // MARK: 이미지
        switch message.content {
        case .image(let imageUrl):
            messageImageWrapperView.isHidden = false
            messageTextWrapperView.isHidden = true
            self.imageUrl = imageUrl
            messageImageView.loadImageWithSpinner(from: imageUrl)
            messageImageTimeLabel.text = message.timeText
        case .text(let text):
            messageImageWrapperView.isHidden = true
            messageTextWrapperView.isHidden = false
            imageUrl = nil
            messageTextLabel.attributedText = NSAttributedString(
                string: text,
                attributes: messageTextLabelAttributes
            )
            messageTextTimeLabel.text = message.timeText
        }
    }
}

extension ChatRightCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        messageImageView.image = nil
        imageUrl = nil
        subscriptions.forEach {
            $0.cancel()
        }
        subscriptions.removeAll()
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        messageImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func imageTapped() {
        if let imageUrl {
            imageTappedPublisher.send(imageUrl)
        }
    }
}

extension ChatRightCell {
    
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
            $0.alignment = .trailing
            $0.distribution = .fillProportionally
        }
        
        // MARK: 이미지
        messageImageView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.isUserInteractionEnabled = true
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 12
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
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentsStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8).priority(999)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        // MARK: 프로필
        profileWrapperView.snp.makeConstraints {
            $0.height.equalTo(0)
        }
        
        // MARK: 이미지
        messageImageView.snp.makeConstraints {
            $0.size.equalTo(168)
            $0.top.trailing.bottom.equalTo(messageImageWrapperView)
        }
        messageImageTimeLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.trailing.equalTo(messageImageView.snp.leading).offset(-8)
            $0.bottom.leading.equalTo(messageImageWrapperView)
        }
        
        // MARK: 텍스트
        messageTextView.snp.makeConstraints {
            $0.top.trailing.bottom.equalTo(messageTextWrapperView)
        }
        messageTextLabel.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(UIScreen.main.bounds.width / 2)
            $0.top.bottom.equalTo(messageTextView).inset(8)
            $0.leading.trailing.equalTo(messageTextView).inset(12)
        }
        messageTextTimeLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.trailing.equalTo(messageTextView.snp.leading).offset(-8)
            $0.bottom.leading.equalTo(messageTextWrapperView)
        }
    }
}
