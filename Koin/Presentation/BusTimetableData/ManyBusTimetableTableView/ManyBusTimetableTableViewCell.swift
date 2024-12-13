//
//  ManyBusTimetableTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/7/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class ManyBusTimetableTableViewCell: UITableViewCell {
    //MARK: - UI Components
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
    
    func configure(busPlace: String, subBusPlace: String?) {
        let isSubBusPlace = subBusPlace != nil ? true : false
        setUpConstraints(isSubBusPlace: isSubBusPlace)
        busPlaceLabel.text = busPlace
        subBusPlaceLabel.text = subBusPlace ?? ""
    }
}

extension ManyBusTimetableTableViewCell {
    private func setUpLayouts() {
        [busPlaceLabel, subBusPlaceLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints(isSubBusPlace: Bool) {
        busPlaceLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalTo(132)
            $0.height.equalTo(26)
            $0.leading.equalToSuperview().offset(24)
        }
        subBusPlaceLabel.snp.makeConstraints {
            $0.top.equalTo(busPlaceLabel.snp.bottom)
            $0.leading.equalTo(busPlaceLabel)
            $0.height.equalTo(19)
        }
    }
    
    private func configureView() {
        setUpLayouts()
    }
}

