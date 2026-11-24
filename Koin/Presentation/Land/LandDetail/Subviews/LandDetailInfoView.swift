//
//  LandDetailInfoView.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import SnapKit

final class LandDetailInfoView: UIView {

    // MARK: - UI Components
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let rowStackView = UIStackView()
    private let rentValueLabel = UILabel()
    private let depositValueLabel = UILabel()
    private let sizeValueLabel = UILabel()
    private let roomTypeValueLabel = UILabel()

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandDetailInfoView {
    func configure(landDetail: LandDetail) {
        rentValueLabel.text = landDetail.rentText
        depositValueLabel.text = landDetail.depositText
        sizeValueLabel.text = landDetail.sizeText
        roomTypeValueLabel.text = landDetail.roomTypeText
    }
}

extension LandDetailInfoView {
    private func makeRow(title: String, valueLabel: UILabel) -> UIView {
        let titleLabel = UILabel()
        titleLabel.do {
            $0.text = title
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.ColorSystem.Neutral.gray600
        }
        valueLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral700)
            $0.numberOfLines = 0
        }
        let rowView = UIView()
        [titleLabel, valueLabel].forEach {
            rowView.addSubview($0)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(19)
        }
        valueLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing)
            $0.trailing.top.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(19)
        }
        return rowView
    }
}

extension LandDetailInfoView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        stackView.do {
            $0.axis = .vertical
            $0.spacing = 8
        }
        titleLabel.do {
            $0.text = "원룸 정보"
            $0.font = .appFont(.pretendardMedium, size: 16)
            $0.textColor = .appColor(.neutral700)
        }
        rowStackView.do {
            $0.axis = .vertical
            $0.spacing = 8
        }
    }

    private func setUpLayouts() {
        addSubview(stackView)
        [titleLabel, rowStackView].forEach {
            stackView.addArrangedSubview($0)
        }
        [
            makeRow(title: "월세/ 전세", valueLabel: rentValueLabel),
            makeRow(title: "보증금/ 관리비", valueLabel: depositValueLabel),
            makeRow(title: "방크기", valueLabel: sizeValueLabel),
            makeRow(title: "방종류", valueLabel: roomTypeValueLabel)
        ].forEach {
            rowStackView.addArrangedSubview($0)
        }
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(26)
        }
    }
}
