//
//  BusTimetableTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/28/24.
//

import SnapKit
import UIKit

final class BusTimetableTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private let leftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 13)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let rightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 13)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViewLayers()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViewLayers()
        setUpLayout()
    }
}

extension BusTimetableTableViewCell {
    func configure(arrivalInfo: BusArrivalInfo) {
        self.leftLabel.text = arrivalInfo.leftNode
        self.rightLabel.text = arrivalInfo.rightNode
    }
}

extension BusTimetableTableViewCell {
    private func setUpViewLayers() {
        contentView.addSubview(self.leftLabel)
        contentView.addSubview(self.rightLabel)
    }
    
    private func setUpLayout() {
        leftLabel.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width / 2.4)
            $0.centerX.equalToSuperview().offset(-81.75)
            $0.centerY.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(81.75)
            $0.centerY.equalToSuperview()
        }
    }
}
