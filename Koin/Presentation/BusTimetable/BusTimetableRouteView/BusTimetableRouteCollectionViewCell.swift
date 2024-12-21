//
//  ShuttleTimetableRouteCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/29/24.
//

import UIKit

final class BusTimetableRouteCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    private let routeLabel = UILabel().then {
        $0.textAlignment = .center
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        configureView()
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isSelected: Bool, route: String) {
        routeLabel.text = route
        routeLabel.font = isSelected ? .appFont(.pretendardBold, size: 14) : .appFont(.pretendardMedium, size: 14)
        routeLabel.textColor = isSelected ? .appColor(.neutral0) : .appColor(.neutral500)
        contentView.backgroundColor = isSelected ? .appColor(.primary500) : .clear
    }
}

extension BusTimetableRouteCollectionViewCell {
    private func setUpLayouts() {
        [routeLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        routeLabel.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.height.equalTo(34)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        contentView.layer.cornerRadius = 17
    }
}

