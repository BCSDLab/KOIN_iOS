//
//  PointLabel.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import UIKit

final class PointLabel: UIView {
    // MARK: - Properties
    private let isRequired: Bool

    // MARK: - UI Components
    private let starLabel = UILabel()
    private let mainLabel = UILabel()

    init(text: String, isRequired: Bool = true) {
        self.isRequired = isRequired
        super.init(frame: .zero)
        mainLabel.text = text
        configureView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setText(text: String) { mainLabel.text = text }
    func getText() -> String { mainLabel.text ?? "" }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        starLabel.text = "*"
        starLabel.font = .appFont(.pretendardRegular, size: 16)
        starLabel.textColor = isRequired ? .appColor(.new600) : .clear
        starLabel.isAccessibilityElement = false
        mainLabel.font = .appFont(.pretendardSemiBold, size: 12)
        mainLabel.textColor = .appColor(.neutral800)
    }

    private func setUpLayouts() {
        [starLabel, mainLabel].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        starLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(8)
        }
        mainLabel.snp.makeConstraints {
            $0.leading.equalTo(starLabel.snp.trailing)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(19)
        }
    }
}
