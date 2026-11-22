//
//  LandListFocusedView.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import Combine
import SnapKit

final class LandListFocusedView: UIView {

    // MARK: - Properties
    let closeTappedPublisher = PassthroughSubject<Void, Never>()
    let detailTappedPublisher = PassthroughSubject<LandRow, Never>()
    private var row: LandRow?

    // MARK: - UI Components
    private let nameLabel = UILabel()
    private let roomTypeLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let addressLabel = UILabel()
    private let monthlyBadge = LandListBadgeView(style: .monthly)
    private let charterBadge = LandListBadgeView(style: .charter)
    private let titleStackView = UIStackView()
    private let badgeStackView = UIStackView()
    private let detailButton = UIButton()

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        detailButton.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandListFocusedView {
    func configure(row: LandRow) {
        self.row = row
        nameLabel.text = row.name
        roomTypeLabel.text = row.roomType
        addressLabel.text = row.address
        monthlyBadge.isHidden = !row.isMonthlyAvailable
        charterBadge.isHidden = !row.isCharterAvailable
        badgeStackView.isHidden = !row.isMonthlyAvailable && !row.isCharterAvailable
    }
}

extension LandListFocusedView {
    @objc private func closeButtonTapped() {
        closeTappedPublisher.send()
    }

    @objc private func detailButtonTapped() {
        guard let row else { return }
        detailTappedPublisher.send(row)
    }
}

extension LandListFocusedView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        nameLabel.do {
            $0.font = .appFont(.pretendardSemiBold, size: 16)
            $0.textColor = .appColor(.neutral800)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        roomTypeLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 10)
            $0.textColor = UIColor.ColorSystem.Neutral.gray600
        }
        closeButton.do {
            $0.setImage(UIImage.appImage(asset: .cancel)?.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = .appColor(.neutral800)
            $0.accessibilityLabel = "닫기"
        }
        addressLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.ColorSystem.Neutral.gray600
        }
        titleStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
        badgeStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }
        var detailConfiguration = UIButton.Configuration.plain()
        detailConfiguration.attributedTitle = AttributedString("매물 상세보기", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardMedium, size: 14),
            .foregroundColor: UIColor.appColor(.neutral0)
        ]))
        detailConfiguration.background.backgroundColor = .appColor(.new500)
        detailConfiguration.background.cornerRadius = 8
        detailConfiguration.cornerStyle = .fixed
        detailButton.configuration = detailConfiguration
    }
    
    private func setUpLayouts() {
        [nameLabel, roomTypeLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [monthlyBadge, charterBadge].forEach {
            badgeStackView.addArrangedSubview($0)
        }
        [titleStackView, closeButton, addressLabel, badgeStackView, detailButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-8)
            $0.height.equalTo(26)
        }
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleStackView)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(24)
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        badgeStackView.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        detailButton.snp.makeConstraints {
            $0.height.equalTo(38)
            $0.top.equalTo(badgeStackView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
