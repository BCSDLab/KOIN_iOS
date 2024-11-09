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
        $0.textColor = .appColor(.info700)
    }
    
    private let afternoonBusTimeLabel = UILabel().then {
        $0.textColor = .appColor(.neutral800)
    }
   
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}

extension ExpressOrCityTimetableTableViewCell {
    private func setUpTimeLabels() {
        [morningBusTimeLabel, afternoonBusTimeLabel].forEach {
            $0.font = .appFont(.pretendardMedium, size: 16)
            $0.textAlignment = .left
            $0.layer.addBorder([.bottom], color: .appColor(.neutral200), width: 1)
        }
    }
    private func setUpLayouts() {
        [morningBusTimeLabel, afternoonBusTimeLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        morningBusTimeLabel.snp.makeConstraints {
            $0.width.equalTo((UIScreen.main.bounds.width - 48) / 2)
            $0.leading.equalToSuperview().offset(24)
            $0.top.bottom.equalToSuperview()
        }
        afternoonBusTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(morningBusTimeLabel.snp.trailing)
            $0.trailing.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpTimeLabels()
        setUpLayouts()
        setUpConstraints()
    }
}
