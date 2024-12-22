//
//  ManyBusTimetableCollectionViewHeaderCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/7/24.
//

import SnapKit
import Then
import UIKit

final class ManyBusTimetableCollectionViewHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "manyBusTimetableCollectionViewHeaderCell"
    
    // MARK: - UI Components
    private let busTimeNumberLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral600)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(busTimeNumber: String) {
        busTimeNumberLabel.text = busTimeNumber
    }
}

extension ManyBusTimetableCollectionViewHeaderCell {
    private func setUpLayouts() {
        [busTimeNumberLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busTimeNumberLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(22)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        contentView.backgroundColor = .appColor(.neutral100)
    }
}

