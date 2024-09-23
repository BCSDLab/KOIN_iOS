//
//  RecommendedSearchCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import SnapKit
import Then
import UIKit

final class RecommendedSearchCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
 
    private let keyWordLabel = UILabel().then {
        $0.textColor = .appColor(.neutral500)
        $0.font = .appFont(.pretendardMedium, size: 14)
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
    
    func configure(keyWord: String) {
        keyWordLabel.text = keyWord
    }
}

extension RecommendedSearchCollectionViewCell {
    private func setUpLayouts() {
        contentView.addSubview(keyWordLabel)
    }
    
    private func setUpConstraints() {
        keyWordLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(34)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .appColor(.neutral100)
    }
}

