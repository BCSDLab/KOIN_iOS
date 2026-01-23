//
//  EditLostItemContentView.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import UIKit
import Combine

final class EditLostItemContentView: UIView {
    
    // MARK: - Properties
    private var type: LostItemType
    private var content: String?
    private let maxCharacters = 1000
    private lazy var textViewPlaceHolder = "물품이나 \(type.description) 장소에 대한 추가 설명이 있다면 작성해주세요."
    let shouldDismissDropDownPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let contentLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.text = "내용"
    }
    private lazy var contentTextCountLabel = UILabel().then {
        if let content {
            $0.text = "\(content.count)/\(maxCharacters)"
        } else {
            $0.text = "0/1000"
        }
        $0.textColor = UIColor.appColor(.gray)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
    }
    private(set) lazy var contentTextView = UITextView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 0)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        if let content, 0 < content.count {
            $0.text = content
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral800)
        } else {
            $0.text = textViewPlaceHolder
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
    }
    
    // MARK: - Initializer
    init(type: LostItemType, content: String?) {
        self.type = type
        self.content = content
        super.init(frame: .zero)
        configureView()
        setDelegate()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditLostItemContentView {
    
    private func setDelegate() {
        contentTextView.delegate = self
    }
}

extension EditLostItemContentView: UITextViewDelegate {
            
    // MARK: 내용 수정 시작
    func textViewDidBeginEditing(_ textView: UITextView) {
        shouldDismissDropDownPublisher.send()
        
        // placeholder 비우기
        if textView.text == textViewPlaceHolder && textView.textColor == UIColor.appColor(.neutral500) {
            textView.text = ""
            textView.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    // MARK: 내용 수정
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count > maxCharacters {
            textView.text = String(textView.text.prefix(maxCharacters))
        }
        contentTextCountLabel.text = "\(textView.text.count)/\(maxCharacters)"
    }
    
    // MARK: 내용 수정 완료
    func textViewDidEndEditing(_ textView: UITextView) {
        endEditing(true)
        
        // placeholder 만들기
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = UIColor.appColor(.neutral500)
        }
    }
    
    // MARK: 내용 수정 완료
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        endEditing(true)
        
        // placeholder 만들기
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = UIColor.appColor(.neutral500)
        }
        
        return true
    }
}

extension EditLostItemContentView {
    
    private func setUpLayouts() {
        [contentLabel, contentTextCountLabel, contentTextView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        contentTextCountLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(22)
        }
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(59)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
