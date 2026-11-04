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
    private let shuttleRouteTypeLabel = BusRouteTagLabel()
    
    private let shuttleBusRouteLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 16)
        $0.textColor = .appColor(.neutral800)
        $0.textAlignment = .left
    }
    
    private let busRouteSubLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let arrowRightImage = UIImageView().then {
        $0.image = .appImage(asset: .chevronRightHome)?.withTintColor(.appColor(.neutral500), renderingMode: .alwaysOriginal)
    }
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(routeType: ShuttleRouteType, route: String, subRoute: String?) {
        shuttleBusRouteLabel.text = route
        shuttleRouteTypeLabel.configure(shuttleRouteType: routeType)
        if let subRoute = subRoute {
            busRouteSubLabel.isHidden = false
            busRouteSubLabel.text = subRoute
        }
        else {
            busRouteSubLabel.isHidden = true
        }
    }
}

extension ShuttleTimetableTableViewCell {
    private func setUpLayouts() {
        [shuttleRouteTypeLabel, shuttleBusRouteLabel, arrowRightImage, busRouteSubLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        shuttleRouteTypeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.centerY.equalTo(shuttleBusRouteLabel)
            $0.height.equalTo(18)
        }
        shuttleBusRouteLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalTo(shuttleRouteTypeLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualTo(arrowRightImage.snp.leading).offset(-8)
            $0.height.equalTo(26)
        }
        arrowRightImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(24)
            $0.width.height.equalTo(24)
        }
        busRouteSubLabel.snp.makeConstraints {
            $0.leading.equalTo(shuttleRouteTypeLabel)
            $0.top.equalTo(shuttleBusRouteLabel.snp.bottom)
            $0.trailing.lessThanOrEqualTo(arrowRightImage.snp.leading).offset(-8)
            $0.height.equalTo(19)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
