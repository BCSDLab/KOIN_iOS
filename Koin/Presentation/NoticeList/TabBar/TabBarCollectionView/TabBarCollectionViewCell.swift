//
//  TabBarCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Combine
import SnapKit
import UIKit
import Then

final class TabBarCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    let tabTitle = UILabel().then {
        $0.textAlignment = .center
        $0.font = .appFont(.pretendardMedium, size: 14)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, isSelected: Bool) {
        tabTitle.text = title
        if isSelected {
            tabTitle.textColor = .appColor(.primary500)
        }
        else {
            tabTitle.textColor = .appColor(.neutral500)
        }
    }
    
    func configure(color: UIColor) {
        self.backgroundColor = color
    }
}

extension TabBarCollectionViewCell {
    private func setUpLayouts() {
        [tabTitle].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        tabTitle.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
