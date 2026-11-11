//
//  ClassComponentView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class ClassComponentView: UIView, UITextFieldDelegate {
    // MARK: - Properties
    let textChangedPublisher = PassthroughSubject<String, Never>()
    private let fieldTitle: String

    // MARK: - UI Components
    private let fieldLabel: PointLabel
    private let textField = UITextField()

    init(text: String, isPoint: Bool) {
        fieldTitle = text
        fieldLabel = PointLabel(text: text, isRequired: isPoint)
        super.init(frame: .zero)
        configureView()
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var textValue: String { textField.text ?? "" }
    func setText(_ text: String) { textField.text = text }
    @objc private func textChanged() { textChangedPublisher.send(textValue) }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        layer.borderColor = UIColor.appColor(.neutral300).cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 16
        textField.font = .appFont(.pretendardRegular, size: 12)
        textField.textColor = .appColor(.neutral800)
        textField.tintColor = .appColor(.new500)
        textField.accessibilityLabel = fieldTitle
        textField.attributedPlaceholder = NSAttributedString(
            string: "\(fieldTitle)\(fieldTitle.hasFinalConsonant() ? "을" : "를") 입력하세요.",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor: UIColor.appColor(.neutral500)
            ]
        )
    }

    private func setUpLayouts() {
        [fieldLabel, textField].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        fieldLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(48)
        }
        textField.snp.makeConstraints {
            $0.leading.equalTo(fieldLabel.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.bottom.equalToSuperview()
        }
    }
}
