//
//  RecruitPostTextViewView.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class RecruitPostTextViewView: UIView {
    
    // MARK: - Properties
    let textChangedPublisher = PassthroughSubject<String?, Never>()
    private let limit: Int
    
    // MARK: - UI Components
    private let headerView: RecruitPostSectionHeaderView
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    
    // MARK: - Initializer
    init(
        title: String,
        isRequired: Bool,
        limit: Int,
        placeholder: String
    ) {
        self.headerView = RecruitPostSectionHeaderView(
            title: title,
            isRequired: isRequired,
            limit: limit
        )
        self.limit = limit
        super.init(frame: .zero)
        configureView()
        setUpDelegate()
        setUpPlaceholder(placeholder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(text: String?) {
        textView.text = text
        placeholderLabel.isHidden = !(text?.isEmpty ?? true)
        headerView.updateCounter(current: text?.count ?? 0, limit: limit)
    }
}

extension RecruitPostTextViewView: UITextViewDelegate {
    private func setUpDelegate() {
        textView.delegate = self
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = String(textView.text.prefix(limit))
        
        textView.text = text
        placeholderLabel.isHidden = !text.isEmpty
        textChangedPublisher.send(text)
        
        headerView.updateCounter(current: text.count, limit: limit)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = String(textView.text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(limit))
        
        textView.text = text
        placeholderLabel.isHidden = !text.isEmpty
        textChangedPublisher.send(text)
        
        headerView.updateCounter(current: text.count, limit: limit)
    }
}

extension RecruitPostTextViewView {
    private func setUpPlaceholder(_ placeholder: String) {
        placeholderLabel.text = placeholder
    }
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        textView.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
            $0.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            $0.textContainer.lineFragmentPadding = 0
        }
        placeholderLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral500)
            $0.numberOfLines = 0
        }
    }
    
    private func setUpLayouts() {
        [headerView, textView, placeholderLabel].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        textView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(151)
        }
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(textView).offset(8)
            $0.leading.trailing.equalTo(textView).inset(12)
        }
    }
}
