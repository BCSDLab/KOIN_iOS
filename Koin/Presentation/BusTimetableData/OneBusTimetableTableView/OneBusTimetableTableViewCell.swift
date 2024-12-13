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
   
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configure(busTime: String, busPlace: String) {
        busTimeLabel.text = busTime
        busPlaceLabel.text = busPlace
    }
}

extension OneBusTimetableTableViewCell {
    private func setUpLayouts() {
        [busTimeLabel, busPlaceLabel].forEach {
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
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

