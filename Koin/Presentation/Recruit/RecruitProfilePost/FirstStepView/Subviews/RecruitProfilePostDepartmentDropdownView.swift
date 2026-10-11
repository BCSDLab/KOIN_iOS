//
//  RecruitProfilePostDepartmentDropdownView.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitProfilePostDepartmentDropdownView: UIView, KoinDropdownContentView {

    // MARK: - Properties
    private let dismissTappedSubject = PassthroughSubject<Void, Never>()
    
    var dismissTappedPublisher: AnyPublisher<Void, Never> {
        dismissTappedSubject.eraseToAnyPublisher()
    }
    var height: CGFloat {
        let visibleRows = min(departments.count, 5)
        return CGFloat(visibleRows) * 34 + 6 * 2
    }

    private let onSelect: (String) -> Void
    private var departments: [String] = []
    
    // MARK: - UI Component
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []

    // MARK: - Initializer
    init(
        onSelect: @escaping (String) -> Void
    ) {
        self.onSelect = onSelect
        super.init(frame: .zero)
        configureView()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(departments: [String]) {
        self.departments = departments
        buttons.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        buttons = departments.enumerated().map { makeButton(for: $0.element, at: $0.offset) }
        buttons.forEach {
            stackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.height.equalTo(34)
            }
        }
        scrollView.isScrollEnabled = departments.count > 5
    }
}

extension RecruitProfilePostDepartmentDropdownView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpLayouts() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        stackView.snp.makeConstraints {
            $0.top.bottom.equalTo(scrollView.contentLayoutGuide).inset(6)
            $0.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
    }

    private func setUpStyles() {
        self.do {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
        }

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
        }

        stackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }
    }
}

extension RecruitProfilePostDepartmentDropdownView {
    private func makeButton(for department: String, at index: Int) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(
            department,
            attributes: AttributeContainer([
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor: UIColor.appColor(.neutral800)
            ])
        )
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0)

        let button = UIButton(configuration: configuration)

        button.contentHorizontalAlignment = .leading
        button.configurationUpdateHandler = { button in
            var configuration = button.configuration
            let backgroundColor = UIColor.appColor(button.isHighlighted ? .neutral100 : .neutral0)
            configuration?.background.backgroundColor = backgroundColor
            button.configuration = configuration
        }
        button.tag = index
        button.addTarget(self, action: #selector(departmentButtonTapped(_:)), for: .touchUpInside)

        return button
    }

    @objc private func departmentButtonTapped(_ sender: UIButton) {
        guard departments.indices.contains(sender.tag) else { return }
        onSelect(departments[sender.tag])
        dismissTappedSubject.send()
    }
}
