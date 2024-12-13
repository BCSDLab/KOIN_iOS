//
//  OneBusTimetableTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/5/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class OneBusTimetableTableViewCell: UITableViewCell {
    //MARK: - UI Components
    private let busTimeLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let busPlaceLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 16)
        $0.textAlignment = .left
        $0.textColor = .black
    }
    
    private let subBusPlaceLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.textAlignment = .left
    }
   
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configure(busPlace: NodeInfo, busTime: String?) {
        busTimeLabel.text = busTime
        busPlaceLabel.text = busPlace.name
        subBusPlaceLabel.text = busPlace.detail
    }
}

extension OneBusTimetableTableViewCell {
    private func setUpLayouts() {
        [busTimeLabel, busPlaceLabel, subBusPlaceLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busTimeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(62)
        }
        busPlaceLabel.snp.makeConstraints {
            $0.centerY.equalTo(busTimeLabel)
            $0.leading.equalTo(busTimeLabel.snp.trailing).offset(18)
        }
        subBusPlaceLabel.snp.makeConstraints {
            $0.top.equalTo(busPlaceLabel.snp.bottom)
            $0.leading.equalTo(busPlaceLabel)
            $0.height.equalTo(19)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

