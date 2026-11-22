//
//  LandListBadgeView.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import SnapKit

final class LandListBadgeView: UIView {
    enum Style {
        case monthly
        case charter

        var title: String {
            switch self {
            case .monthly: LandListFilter.monthly.displayName
            case .charter: LandListFilter.charter.displayName
            }
        }
        var textColor: ColorAsset {
            switch self {
            case .monthly: .success700
            case .charter: .warning600
            }
        }
        var backgroundColor: ColorAsset {
            switch self {
            case .monthly: .success200
            case .charter: .warning100
            }
        }
    }

    // MARK: - Properties
    private let style: Style

    // MARK: - UI Components
    private let titleLabel = UILabel()

    // MARK: - Initializer
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandListBadgeView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(style.backgroundColor)
        layer.cornerRadius = 9
        clipsToBounds = true
        titleLabel.do {
            $0.text = style.title
            $0.font = .appFont(.pretendardMedium, size: 10)
            $0.textColor = .appColor(style.textColor)
        }
    }

    private func setUpLayouts() {
        addSubview(titleLabel)
    }

    private func setUpConstraints() {
        snp.makeConstraints {
            $0.height.equalTo(18)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
        }
    }
}
