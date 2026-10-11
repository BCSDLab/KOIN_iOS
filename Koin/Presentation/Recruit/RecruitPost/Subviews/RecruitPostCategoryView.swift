//
//  RecruitPostCategoryView.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class RecruitPostCategoryView: UIView {
    
    // MARK: - Properties
    let categoryButtonTappedPublisher = PassthroughSubject<Void, Never>()
    private let placeholder = "카테고리를 선택해주세요."
    
    var dropdownAnchor: UIView { categoryButton }
    
    // MARK: - UI Components
    private let headerView = RecruitPostSectionHeaderView(title: "카테고리", isRequired: true)
    private let categoryButton = UIButton()
    private let categoryLabel = UILabel()
    private let chevronDownImageView = UIImageView(image: .appImage(asset: .chevronDown))
    
    // MARK: - Initializer
    init(category: RecruitCategory = .contest) {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(category: RecruitCategory?) {
        categoryLabel.text = category?.rawValue ?? placeholder
        categoryLabel.textColor = category == nil ? UIColor.appColor(.neutral500) : UIColor.appColor(.neutral800)
    }
}

extension RecruitPostCategoryView {
    private func setAddTargets() {
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
    }
    
    @objc private func categoryButtonTapped() {
        categoryButtonTappedPublisher.send()
    }
}

extension RecruitPostCategoryView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        categoryButton.do {
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .appColor(.neutral0)
        }
        categoryLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.text = placeholder
        }
        chevronDownImageView.do {
            $0.image = UIImage.appImage(asset: .chevronDown)
            $0.contentMode = .scaleAspectFit
        }
    }
    
    private func setUpLayouts() {
        [headerView, categoryButton].forEach {
            addSubview($0)
        }
        [categoryLabel, chevronDownImageView].forEach {
            categoryButton.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        categoryButton.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
        categoryLabel.snp.makeConstraints {
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
