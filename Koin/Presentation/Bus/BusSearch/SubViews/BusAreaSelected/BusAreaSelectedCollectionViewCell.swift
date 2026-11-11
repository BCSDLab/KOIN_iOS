//
//  BusAreaSelectedCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import UIKit

final class BusAreaSelectedCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    private let busPlaceLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .appFont(.pretendardSemiBold, size: 14)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(busPlace: String, isSelected: Bool) {
        busPlaceLabel.text = busPlace
        busPlaceLabel.textColor = isSelected ? .appColor(.new500) : .appColor(.neutral500)
        contentView.layer.borderColor = isSelected ? UIColor.appColor(.new500).cgColor : UIColor.appColor(.neutral300).cgColor
    }
    
    func disableCell() {
        busPlaceLabel.textColor = .appColor(.neutral300)
        contentView.layer.borderColor = UIColor.appColor(.neutral300).cgColor
    }
}

extension BusAreaSelectedCollectionViewCell {
    private func setUpLayouts() {
        [busPlaceLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busPlaceLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        contentView.layer.cornerRadius = 17
        contentView.layer.borderWidth = 1
    }
}
