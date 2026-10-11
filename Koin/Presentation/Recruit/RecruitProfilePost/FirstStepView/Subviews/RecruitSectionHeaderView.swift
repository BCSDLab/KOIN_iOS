//
//  RecruitSectionHeaderView.swift
//  koin
//
//  Created by 홍기정 on 9/14/26.
//

import SnapKit
import Then
import UIKit

final class RecruitSectionHeaderView: UIView {
    
    // MARK: - Properties
    private var currentAxis: NSLayoutConstraint.Axis = .horizontal
    
    // MARK: - UI Components
    private let headerStackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // MARK: - Initializer
    init(
        title: String,
        description: String
    ) {
        super.init(frame: .zero)
        configureView()
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
    init(
        attributedTitle: NSAttributedString,
        description: String
    ) {
        super.init(frame: .zero)
        configureView()
        titleLabel.attributedText = attributedTitle
        descriptionLabel.text = description
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecruitSectionHeaderView {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        guard bounds.width > 0 else { return }
        let requiredWidth = titleLabel.intrinsicContentSize.width
            + 8
            + descriptionLabel.intrinsicContentSize.width
        let nextAxis: NSLayoutConstraint.Axis = bounds.width >= requiredWidth ? .horizontal : .vertical
        guard currentAxis != nextAxis else { return }

        currentAxis = nextAxis
        headerStackView.axis = nextAxis
        headerStackView.alignment = nextAxis == .horizontal ? .center : .leading
        headerStackView.spacing = nextAxis == .horizontal ? 8 : 0
        invalidateIntrinsicContentSize()
    }
}

extension RecruitSectionHeaderView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        titleLabel.do {
            $0.textColor = .appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 16)
        }
        descriptionLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral500)
        }
        headerStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 8
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, descriptionLabel].forEach {
            headerStackView.addArrangedSubview($0)
        }
        [headerStackView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        headerStackView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(26)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
        }
    }
}
