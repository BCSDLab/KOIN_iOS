//
//  BusTimetableTableViewHeader.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/28/24.
//

import SnapKit
import UIKit

final class BusTimetableTableViewHeaderView: UITableViewHeaderFooterView {
    // MARK: - UI Components
    private let leftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 16)
        label.textColor = .black
        return label
    }()
    
    private let rightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 16)
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUpViewLayers()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViewLayers()
        setUpLayout()
    }
}

extension BusTimetableTableViewHeaderView {
    func configure(headerInfo: (String, String)) {
        self.leftLabel.text = headerInfo.0
        self.rightLabel.text = headerInfo.1
    }
}

extension BusTimetableTableViewHeaderView {
    private func setUpViewLayers() {
        contentView.addSubview(self.leftLabel)
        contentView.addSubview(self.rightLabel)
    }
    
    private func setUpLayout() {
        leftLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(-81.75)
            $0.centerY.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(81.75)
            $0.centerY.equalToSuperview()
        }
    }
}
