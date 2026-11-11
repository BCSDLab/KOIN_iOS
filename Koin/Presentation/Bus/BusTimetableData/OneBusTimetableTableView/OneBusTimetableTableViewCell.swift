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
        $0.textColor = .appColor(.neutral800)
    }
    
    private let busPlaceLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 16)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral800)
    }
    
    private let subBusPlaceLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.textAlignment = .left
    }
    
    private lazy var busPlaceStackView = UIStackView(arrangedSubviews: [busPlaceLabel, subBusPlaceLabel]).then {
        $0.axis = .vertical
        $0.alignment = .leading
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
        subBusPlaceLabel.isHidden = (busPlace.detail ?? "").isEmpty
    }
}

extension OneBusTimetableTableViewCell {
    private func setUpLayouts() {
        [busTimeLabel, busPlaceStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        // 한 줄이면 행 중앙, 두 줄이면 정류장명 26 + 부명칭 19 묶음을 행 중앙에 둔다(UIKit 라벨 높이를 피그마 줄높이로 고정).
        busPlaceStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(busTimeLabel.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(24)
        }
        busPlaceLabel.snp.makeConstraints {
            $0.height.equalTo(26)
        }
        subBusPlaceLabel.snp.makeConstraints {
            $0.height.equalTo(19)
        }
        busTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(busPlaceLabel)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(62)
            $0.height.equalTo(26)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

