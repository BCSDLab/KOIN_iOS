//
//  ManyBusTimetableCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/7/24.
//

import SnapKit
import Then
import UIKit

final class ManyBusTimetableCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    private let busTimeLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.neutral800)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(busTime: String?) {
        busTimeLabel.text = busTime ?? ""
    }
}

extension ManyBusTimetableCollectionViewCell {
    private func setUpLayouts() {
        [busTimeLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busTimeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}


