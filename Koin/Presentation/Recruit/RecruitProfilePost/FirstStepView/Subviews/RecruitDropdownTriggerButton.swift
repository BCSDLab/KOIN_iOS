//
//  RecruitDropdownTriggerButton.swift
//  koin
//
//  Created by 홍기정 on 9/15/26.
//

import SnapKit
import Then
import UIKit

final class RecruitDropdownTriggerButton: UIButton {

    // MARK: - Properties
    private let placeholder: String

    // MARK: - UI Components
    private let valueLabel = UILabel()
    private let placeholderLabel = UILabel()
    private let chevronDownImageView = UIImageView(image: .appImage(asset: .chevronDown))

    // MARK: - Initializer
    init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(text: String?) {
        valueLabel.text = text
        valueLabel.isHidden = text == nil
        placeholderLabel.isHidden = text != nil
    }
}

extension RecruitDropdownTriggerButton {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        layer.cornerRadius = 16
        backgroundColor = .appColor(.neutral0)

        valueLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.isHidden = true
        }
        placeholderLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.text = placeholder
            $0.textColor = .appColor(.neutral500)
        }
        chevronDownImageView.do {
            $0.image = UIImage.appImage(asset: .chevronDown)
            $0.contentMode = .scaleAspectFit
        }
    }

    private func setUpLayouts() {
        [valueLabel, placeholderLabel, chevronDownImageView].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        valueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.lessThanOrEqualTo(chevronDownImageView.snp.leading).offset(-8)
        }
        placeholderLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.lessThanOrEqualTo(chevronDownImageView.snp.leading).offset(-8)
        }
        chevronDownImageView.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
        }
    }
}
