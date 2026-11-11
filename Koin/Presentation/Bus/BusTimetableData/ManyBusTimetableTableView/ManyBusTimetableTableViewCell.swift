//
//  ManyBusTimetableTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/7/24.
//

import UIKit
import SnapKit

final class ManyBusTimetableTableViewCell: UITableViewCell {
    //MARK: - UI Components
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
    
    private lazy var busLabelStackView = UIStackView(arrangedSubviews: [busPlaceLabel, subBusPlaceLabel]).then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fill
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

    override func prepareForReuse() {
        super.prepareForReuse()
        busPlaceLabel.text = nil
        subBusPlaceLabel.text = nil
        subBusPlaceLabel.isHidden = false
    }

    func configure(busPlace: String, subBusPlace: String?) {
        busPlaceLabel.text = busPlace
        if let sub = subBusPlace, !sub.isEmpty {
            subBusPlaceLabel.text = sub
            subBusPlaceLabel.isHidden = false
        } else {
            subBusPlaceLabel.text = nil
            subBusPlaceLabel.isHidden = true
        }
    }
}

extension ManyBusTimetableTableViewCell {
    private func setUpLayouts() {
        [busLabelStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        // 한 줄이면 행 중앙, 두 줄이면 정류장명 26 + 부명칭 19 묶음을 행 중앙에 둔다(UIKit 라벨 높이를 피그마 줄높이로 고정).
        busLabelStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        busPlaceLabel.snp.makeConstraints {
            $0.height.equalTo(26)
        }
        subBusPlaceLabel.snp.makeConstraints {
            $0.height.equalTo(19)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
