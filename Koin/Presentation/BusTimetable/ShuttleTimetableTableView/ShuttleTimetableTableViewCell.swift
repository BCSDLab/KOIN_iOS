//
//  BusTimetableTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/9/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class ShuttleTimetableTableViewCell: UITableViewCell {  
    //MARK: - UI Components
    private var shuttleRouteTypeLabel = UILabel().then {
        $0.layer.cornerRadius = 8
        $0.font = .appFont(.pretendardRegular, size: 11)
        $0.textAlignment = .center
        $0.textColor = .appColor(.neutral0)
        $0.backgroundColor = .orange
    }
    
    private let shuttleBusRouteLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.textAlignment = .left
    }
    
    private let arrowRightImage = UIImageView().then {
        $0.image = .appImage(asset: .chevronRight)
    }
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(routeType: String, route: String) {
        self.shuttleBusRouteLabel.text = route
        self.shuttleRouteTypeLabel.text = routeType
    }
}

extension ShuttleTimetableTableViewCell {
    private func setUpLayouts() {
        [shuttleRouteTypeLabel, shuttleBusRouteLabel, arrowRightImage].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        shuttleRouteTypeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(28)
            $0.height.equalTo(18)
        }
        shuttleBusRouteLabel.snp.makeConstraints {
            $0.centerY.equalTo(shuttleRouteTypeLabel)
            $0.leading.equalTo(shuttleRouteTypeLabel.snp.trailing).offset(8)
        }
        arrowRightImage.snp.makeConstraints {
            $0.centerY.equalTo(shuttleRouteTypeLabel)
            $0.trailing.equalToSuperview().inset(31)
            $0.width.height.equalTo(17)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
