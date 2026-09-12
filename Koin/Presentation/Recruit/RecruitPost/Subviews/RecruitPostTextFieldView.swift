//
//  RecruitPostTextFieldView.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class RecruitPostTextFieldView: UIView {
    
    // MARK: - Properties
    let textChangedPublisher = PassthroughSubject<String?, Never>()
    private let limit: Int?
    
    // MARK: - UI Components
    private let headerView: RecruitPostSectionHeaderView
    private let textField = UITextField()
    
    // MARK: - Initializer
    init(
        title: String,
        isRequired: Bool,
        limit: Int?,
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
        setAddTargets()
        setUpPlaceholder(placeholder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(text: String?) {
        textField.text = text
        updateCounter(text: text)
    }
}

extension RecruitPostTextFieldView {
    private func setAddTargets() {
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldEditingEnd), for: .editingDidEnd)
    }
    
    @objc private func textFieldEditingChanged() {
        var text = textField.text ?? ""
        if let limit {
            text = String(text.prefix(limit))
        }
        textField.text = text
        textChangedPublisher.send(text)
        updateCounter(text: text)
    }
    
    @objc private func textFieldEditingEnd() {
        var text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if let limit {
            text = String(text.prefix(limit))
        }
        textField.text = text
        textChangedPublisher.send(text)
        updateCounter(text: text)
    }
    
    private func updateCounter(text: String?) {
        if let limit {
            headerView.updateCounter(current: text?.count ?? 0, limit: limit)
        }
    }
}

extension RecruitPostTextFieldView {
    
    private func setUpPlaceholder(_ placeholder: String?) {
        guard let placeholder else { return }
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor: UIColor.appColor(.neutral500)
            ]
        )
    }
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        textField.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
            $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
            $0.rightViewMode = .always
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
            $0.leftViewMode = .always
        }
    }
    
    private func setUpLayouts() {
        [headerView, textField].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        textField.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
