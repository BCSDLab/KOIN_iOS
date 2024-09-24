//
//  NoticeKeywordCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import SnapKit
import Then
import UIKit

final class NoticeKeywordCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    private let keywordLabel = UILabel().then {
        $0.textAlignment = .center
    }
    
    private let filterImageView = UIImageView().then {
        $0.image = .appImage(asset: .filter)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(keywordModel: String, isSelected: Bool) {
        contentView.backgroundColor = .appColor(.neutral100)
        contentView.layer.cornerRadius = 17
        keywordLabel.text = keywordModel
        
        keywordLabel.isHidden = false
        filterImageView.isHidden = true
        
        if isSelected {
            keywordLabel.font = .appFont(.pretendardBold, size: 14)
            keywordLabel.textColor = .appColor(.neutral0)
            contentView.backgroundColor = .appColor(.primary500)
        }
        else {
            keywordLabel.font = .appFont(.pretendardMedium, size: 14)
            keywordLabel.textColor = .appColor(.neutral500)
            contentView.backgroundColor = .appColor(.neutral100)
        }
    }

    func configureFilterImage() {
        contentView.backgroundColor = .appColor(.neutral100)
        contentView.layer.cornerRadius = 16
        keywordLabel.isHidden = true
        filterImageView.isHidden = false
    }
}

extension NoticeKeywordCollectionViewCell {
    private func setUpLayouts() {
        [keywordLabel, filterImageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        keywordLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(34)
            $0.centerX.equalToSuperview()
        }
        
        filterImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20)
            $0.width.equalTo(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
