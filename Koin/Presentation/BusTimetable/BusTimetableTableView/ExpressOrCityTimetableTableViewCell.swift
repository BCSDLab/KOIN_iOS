//
//  ExpressOrCityTimetableTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/9/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class ExpressOrCityTimetableTableViewCell: UITableViewCell {
    //MARK: - UI Components
    private let morningBusTimeLabel = UILabel().then {
        $0.textColor = .appColor(.warning500)
    }
    
    private let afternoonBusTimeLabel = UILabel().then {
        $0.textColor = .appColor(.info700)
    }
    
    private let separatorLine1 = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    
    private let separatorLine2 = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
   
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(morningBusInfo: String, secondBusInfo: String) {
        self.morningBusTimeLabel.text = morningBusInfo
        self.afternoonBusTimeLabel.text = secondBusInfo
    }
    
}

extension ExpressOrCityTimetableTableViewCell {
    private func setUpTimeLabels() {
        [morningBusTimeLabel, afternoonBusTimeLabel].forEach {
            $0.font = .appFont(.pretendardMedium, size: 16)
            $0.textAlignment = .left
        }
    }
    private func setUpLayouts() {
        [morningBusTimeLabel, afternoonBusTimeLabel, separatorLine1, separatorLine2].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        morningBusTimeLabel.snp.makeConstraints {
            $0.width.equalTo((UIScreen.main.bounds.width - 64) / 2)
            $0.leading.equalToSuperview().offset(24)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(61)
        }
        afternoonBusTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(morningBusTimeLabel.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(61)
        }
        separatorLine1.snp.makeConstraints {
            $0.leading.trailing.equalTo(morningBusTimeLabel)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        separatorLine2.snp.makeConstraints {
            $0.leading.trailing.equalTo(afternoonBusTimeLabel)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func configureView() {
        setUpTimeLabels()
        setUpLayouts()
        setUpConstraints()
    }
}
