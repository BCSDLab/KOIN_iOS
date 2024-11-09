//
//  BusTimetableRouteCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/9/24.
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
        fatalError("init(coder:) has not been implemented")
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
            $0.centerY.equalToSuperview()
            $0.height.equalTo(34)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        contentView.layer.cornerRadius = 17
    }
}
