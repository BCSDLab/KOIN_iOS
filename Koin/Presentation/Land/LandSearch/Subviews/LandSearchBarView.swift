//
//  LandSearchBarView.swift
//  koin
//
//  Created by 홍기정 on 11/24/26.
//

import UIKit
import Combine
import SnapKit

final class LandSearchBarView: UIView {

    // MARK: - Properties
    let textChangedPublisher = PassthroughSubject<String, Never>()
    let searchSubmittedPublisher = PassthroughSubject<String, Never>()
    let editingBeganPublisher = PassthroughSubject<Void, Never>()
    let editingEndedPublisher = PassthroughSubject<Void, Never>()
    var isEditing: Bool {
        textField.isEditing
    }
    var text: String {
        textField.text ?? ""
    }

    // MARK: - UI Components
    private let textField = UITextField()
    private let searchButton = UIButton(type: .system)

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: .editingDidEnd)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandSearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitSearch()
        return true
    }
}

extension LandSearchBarView {
    func setText(_ text: String) {
        textField.text = text
    }
}

extension LandSearchBarView {
    @objc private func textFieldEditingChanged() {
        textChangedPublisher.send(textField.text ?? "")
    }

    @objc private func textFieldEditingDidBegin() {
        editingBeganPublisher.send()
    }

    @objc private func textFieldEditingDidEnd() {
        editingEndedPublisher.send()
    }

    @objc private func searchButtonTapped() {
        submitSearch()
    }

    private func submitSearch() {
        textField.resignFirstResponder()
        searchSubmittedPublisher.send(textField.text ?? "")
    }
}

extension LandSearchBarView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor.appColor(.neutral300).cgColor
        textField.do {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral800)
            $0.attributedPlaceholder = NSAttributedString(
                string: "건물 명을 입력해주세요.",
                attributes: [
                    .font: UIFont.appFont(.pretendardRegular, size: 12),
                    .foregroundColor: UIColor.appColor(.neutral500)
                ]
            )
            $0.returnKeyType = .search
            $0.clearButtonMode = .never
        }
        searchButton.do {
            $0.setImage(UIImage.appImage(asset: .noticeSearch)?.withRenderingMode(.alwaysOriginal), for: .normal)
            $0.accessibilityLabel = "검색"
        }
    }

    private func setUpLayouts() {
        [textField, searchButton].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(searchButton.snp.leading).offset(-8)
        }
        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(21)
        }
    }
}
