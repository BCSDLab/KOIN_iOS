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
    private let tabTitle = UILabel().then {
        $0.textAlignment = .center
        $0.font = .appFont(.pretendardMedium, size: 14)
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = .appColor(.primary500)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        tabTitle.text = title
    }
    
    func selectTab(isSelected: Bool) {
        tabTitle.textColor = isSelected ? .appColor(.primary500) : .appColor(.neutral500)
        indicatorView.isHidden = isSelected ? false : true
    }
}

extension TabBarCollectionViewCell {
    private func setUpLayouts() {
        [tabTitle, indicatorView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        tabTitle.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.5)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
