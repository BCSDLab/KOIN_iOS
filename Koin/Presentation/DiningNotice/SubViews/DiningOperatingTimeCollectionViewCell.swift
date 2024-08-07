//
//  DiningOperatingTimeCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 6/8/24.
//

import Combine
import SnapKit
import UIKit

final class DiningOperatingTimeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let separateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral300)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(open: CoopOpenDTO) {
        timeLabel.text = open.type.rawValue
        startTimeLabel.text = open.openTime
        endTimeLabel.text = open.closeTime
    }
    
}

extension DiningOperatingTimeCollectionViewCell {
    private func setUpLayouts() {
        [timeLabel, startTimeLabel, endTimeLabel, separateView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        startTimeLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(self.snp.centerX).offset(-115)
        }
        endTimeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(self.snp.centerX).offset(115)
        }
        separateView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    private func setUpLabels() {
        [timeLabel, startTimeLabel, endTimeLabel].forEach { label in
            label.font = UIFont.appFont(.pretendardRegular, size: 16)
            label.textColor = UIColor.appColor(.neutral800)
            label.textAlignment = .center
        }
    }
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        setUpLabels()
    }
    
}
