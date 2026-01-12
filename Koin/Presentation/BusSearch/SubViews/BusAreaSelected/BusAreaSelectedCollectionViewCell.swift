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
        $0.font = .appFont(.pretendardMedium, size: 15)
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
        if isSelected {
            busPlaceLabel.textColor = .appColor(.neutral0)
            contentView.backgroundColor = .appColor(.primary500)
        }
        else {
            busPlaceLabel.textColor = .appColor(.neutral600)
            contentView.backgroundColor = .appColor(.neutral200)
        }
    }
    
    func disableCell() {
        contentView.backgroundColor = .appColor(.neutral50)
        busPlaceLabel.textColor = .appColor(.neutral300)
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
        contentView.layer.cornerRadius = 4
    }
}
