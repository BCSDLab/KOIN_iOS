//
//  ChatInputView.swift
//  koin
//
//  Created by 홍기정 on 8/20/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class ChatInputView: UIView {
    
    // MARK: - Properties
    let messageSendPublisher = PassthroughSubject<String, Never>()
    let imageSendTappedPublisher = PassthroughSubject<Void, Never>()
    private let textViewPlaceHolder = "메시지 보내기"
    
    // MARK: - UI Components
    private let sendImageButton = UIButton()
    private let messageTextView = UITextView()
    private let sendMessageButton = UIButton()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITextViewDelegate

extension ChatInputView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.appColor(.neutral500) {
            textView.text = ""
            textView.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = UIColor.appColor(.neutral500)
        }
    }
}

// MARK: - Actions

private extension ChatInputView {
    @objc private func sendImageButtonTapped() {
        imageSendTappedPublisher.send()
    }
    
    @objc private func sendMessageButtonTapped() {
        guard messageTextView.textColor == UIColor.appColor(.neutral800) else {
            return
        }
        
        let text = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messageSendPublisher.send(text)
        messageTextView.text = ""
    }
}

// MARK: - Configure

private extension ChatInputView {
    private func configureView() {
        setAddTargets()
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setAddTargets() {
        sendImageButton.addTarget(self, action: #selector(sendImageButtonTapped), for: .touchUpInside)
        sendMessageButton.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
    }
    
    private func setUpStyles() {
        backgroundColor = UIColor.appColor(.neutral100)
        
        sendImageButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanSendImage), for: .normal)
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        
        messageTextView.do {
            let font = UIFont.appFont(.pretendardRegular, size: 12)
            let height: CGFloat = 32
            let topBottomInset = (height - font.lineHeight) / 2
            
            $0.delegate = self
            $0.isScrollEnabled = false
            $0.font = font
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.textContainerInset = UIEdgeInsets(
                top: topBottomInset,
                left: 16,
                bottom: topBottomInset,
                right: 16
            )
            $0.layer.cornerRadius = 12
            $0.text = textViewPlaceHolder
            $0.textColor = UIColor.appColor(.neutral500)
        }
        
        sendMessageButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanSendMessage), for: .normal)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
    }
    
    private func setUpLayouts() {
        [sendImageButton, messageTextView, sendMessageButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        sendImageButton.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(24)
        }
        
        sendMessageButton.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        messageTextView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalTo(sendImageButton.snp.trailing).offset(8)
            $0.trailing.equalTo(sendMessageButton.snp.leading).offset(-8)
            $0.bottom.greaterThanOrEqualTo(sendImageButton)
        }
    }
}
