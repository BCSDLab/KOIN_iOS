//
//  RecruitPostSectionHeaderView.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import SnapKit
import Then

final class RecruitPostSectionHeaderView: UIView {
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let isRequiredLabel = UILabel()
    private let counterLabel = UILabel()
    
    // MARK: - Initializer
    init(
        title: String,
        isRequired: Bool,
        limit: Int? = nil
    ) {
        super.init(frame: .zero)
        configureView(
            title,
            isRequired: isRequired,
            limit: limit
        )
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func updateCounter(current: Int, limit: Int) {
        counterLabel.text = "\(current)/\(limit)"
    }
}
    
extension RecruitPostSectionHeaderView {
    private func configureView(
        _ title: String,
        isRequired: Bool,
        limit: Int?
    ) {
        setUpStyles(
            title,
            isRequired: isRequired,
            limit: limit
        )
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles(
        _ title: String,
        isRequired: Bool,
        limit: Int?
    ) {
        titleLabel.do {
            $0.text = title
            $0.font = .appFont(.pretendardSemiBold, size: 16)
            $0.textColor = .appColor(.neutral800)
        }
        isRequiredLabel.do {
            $0.text = "*"
            $0.font = .appFont(.pretendardSemiBold, size: 16)
            $0.textColor = .appColor(.new500)
            $0.isHidden = !isRequired
        }
        counterLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
            $0.textAlignment = .right
            $0.isHidden = true
        }
        counterLabel.do {
            if let limit {
                $0.isHidden = false
                $0.text = "0/\(limit)"
            } else {
                $0.isHidden = true
            }
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, isRequiredLabel, counterLabel].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        self.snp.makeConstraints {
            $0.height.equalTo(26)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        isRequiredLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(3)
            $0.centerY.equalToSuperview()
        }
        counterLabel.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }
}
