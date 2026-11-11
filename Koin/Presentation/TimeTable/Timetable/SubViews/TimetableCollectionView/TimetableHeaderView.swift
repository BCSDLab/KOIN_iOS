//
//  TimetableHeaderView.swift
//  koin
//
//  Created by 김나훈 on 11/18/24.
//

import UIKit

final class TimetableHeaderView: UICollectionReusableView {
    // MARK: - Properties
    static let identifier = "TimetableHeaderView"

    // MARK: - UI Components
    private let daysStackView = UIStackView()
    private let gridLines = CAShapeLayer()
    private let dayLabels = ["월", "화", "수", "목", "금"].map { day in
        let label = UILabel()
        label.text = day
        return label
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gridLines.frame = bounds
        gridLines.path = TimetableGridMetrics.linePath(in: bounds, includesHalfHour: false)
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        clipsToBounds = false
        daysStackView.axis = .horizontal
        daysStackView.distribution = .fillEqually
        daysStackView.spacing = 0
        dayLabels.forEach {
            $0.textAlignment = .center
            $0.textColor = .appColor(.neutral500)
            $0.font = .appFont(.pretendardMedium, size: 13)
            $0.clipsToBounds = false
        }
        gridLines.strokeColor = UIColor.appColor(.neutral300).cgColor
        gridLines.fillColor = UIColor.clear.cgColor
        gridLines.lineWidth = TimetableGridMetrics.lineWidth
    }

    private func setUpLayouts() {
        layer.addSublayer(gridLines)
        addSubview(daysStackView)
        dayLabels.forEach { daysStackView.addArrangedSubview($0) }
    }

    private func setUpConstraints() {
        daysStackView.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(TimetableGridMetrics.timeColumnWidth)
        }
    }
}
