//
//  LandSearchSuggestionView.swift
//  koin
//
//  Created by 홍기정 on 11/24/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class LandSearchSuggestionView: UIView {

    // MARK: - Properties
    let suggestionTappedPublisher = PassthroughSubject<LandRow, Never>()
    private var rows: [LandRow] = []

    // MARK: - UI Component
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(query: String, rows: [LandRow]) {
        self.rows = rows
        buttons.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        buttons = rows.enumerated().map { makeButton(for: $0.element.name, query: query, at: $0.offset) }
        buttons.forEach {
            stackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.height.equalTo(36)
            }
        }
    }
}

extension LandSearchSuggestionView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpLayouts() {
        addSubview(stackView)
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setUpStyles() {
        self.do {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 8
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.06
            $0.layer.shadowOffset = CGSize(width: 0, height: 1)
            $0.layer.shadowRadius = 4.5
        }

        stackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }
    }
}

extension LandSearchSuggestionView {
    private func makeButton(for name: String, query: String, at index: Int) -> UIButton {
        var title = AttributedString(
            name,
            attributes: AttributeContainer([
                .font: UIFont.appFont(.pretendardRegular, size: 10),
                .foregroundColor: UIColor.ColorSystem.Neutral.gray800
            ])
        )
        if let highlightRange = title.range(of: query, options: .caseInsensitive) {
            title[highlightRange].mergeAttributes(AttributeContainer([
                .foregroundColor: UIColor.appColor(.new500)
            ]))
        }

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = title
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0)

        let button = UIButton(configuration: configuration)

        button.contentHorizontalAlignment = .leading
        button.tag = index
        button.addTarget(self, action: #selector(suggestionButtonTapped(_:)), for: .touchUpInside)

        return button
    }

    @objc private func suggestionButtonTapped(_ sender: UIButton) {
        guard rows.indices.contains(sender.tag) else { return }
        suggestionTappedPublisher.send(rows[sender.tag])
    }
}
