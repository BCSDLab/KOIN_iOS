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
   
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configure(busPlace: String) {
        busPlaceLabel.text = busPlace
    }
}

extension ManyBusTimetableTableViewCell {
    private func setUpLayouts() {
        [busPlaceLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busPlaceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(132)
            $0.leading.equalToSuperview().offset(24)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

