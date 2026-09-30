//
//  RecruitPostCategoryDropdownView.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class RecruitPostCategoryDropdownView: UIView, KoinDropdownContentView {
    
    // MARK: - Properties
    private let dismissTappedSubject = PassthroughSubject<Void, Never>()
    var dismissTappedPublisher: AnyPublisher<Void, Never> {
        dismissTappedSubject.eraseToAnyPublisher()
    }
    let height: CGFloat = 34 * 5 + 12
    private let onSelect: (RecruitCategory) -> Void
    
    private let stackView = UIStackView()
    private lazy var buttons: [UIButton] = RecruitCategory.allCases.map { makeButton(for: $0) }
    
    // MARK: - Initializer
    init(onSelect: @escaping (RecruitCategory) -> Void) {
        self.onSelect = onSelect
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecruitPostCategoryDropdownView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        buttons.forEach {
            stackView.addArrangedSubview($0)
        }
        addSubview(stackView)
    }
    
    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview()
        }
        buttons.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(34)
            }
        }
    }
    
    private func setUpStyles() {
        self.do {
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.layer.cornerRadius = 16
        }
        
        stackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }
    }
}

extension RecruitPostCategoryDropdownView {
    private func makeButton(for category: RecruitCategory) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(
            category.rawValue,
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
        button.tag = category.index
        button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        guard let category = RecruitCategory.allCases.first(where: { $0.index == sender.tag }) else {
            return
        }
        onSelect(category)
        dismissTappedSubject.send()
    }
}
