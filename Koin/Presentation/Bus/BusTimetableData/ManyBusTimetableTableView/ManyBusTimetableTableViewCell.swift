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
        $0.textColor = .black
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
        $0.spacing = 2
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
        busLabelStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
