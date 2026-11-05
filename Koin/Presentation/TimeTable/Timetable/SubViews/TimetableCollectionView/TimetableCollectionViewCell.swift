//
//  TimetableCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/9/24.
//

import UIKit

final class TimetableCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    private let timeLabel = UILabel()
    private let gridLines = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gridLines.frame = contentView.bounds
        gridLines.path = TimetableGridMetrics.linePath(in: contentView.bounds, includesHalfHour: true)
    }

    func configure(text: String) {
        timeLabel.text = text
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        timeLabel.font = .appFont(.pretendardRegular, size: 12)
        timeLabel.textColor = .appColor(.neutral500)
        timeLabel.textAlignment = .center
        gridLines.strokeColor = UIColor.appColor(.neutral300).cgColor
        gridLines.fillColor = UIColor.clear.cgColor
        gridLines.lineWidth = TimetableGridMetrics.lineWidth
    }

    private func setUpLayouts() {
        contentView.layer.addSublayer(gridLines)
        contentView.addSubview(timeLabel)
    }

    private func setUpConstraints() {
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview()
            $0.width.equalTo(TimetableGridMetrics.timeColumnWidth)
        }
    }
}
