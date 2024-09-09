//
//  NoticeKeyWordCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import SnapKit
import Then
import UIKit

final class NoticeKeyWordCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    private let keyWord = UILabel().then {
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
    
    func configure(keyWordModel: String, isSelected: Bool) {
        contentView.backgroundColor = .appColor(.neutral100)
        contentView.layer.cornerRadius = 17
        keyWord.text = keyWordModel
        
        keyWord.isHidden = false
        filterImageView.isHidden = true
        
        if isSelected {
            keyWord.font = .appFont(.pretendardBold, size: 14)
            keyWord.textColor = .appColor(.neutral0)
            contentView.backgroundColor = .appColor(.primary500)
        }
        else {
            keyWord.font = .appFont(.pretendardMedium, size: 14)
            keyWord.textColor = .appColor(.neutral500)
            contentView.backgroundColor = .appColor(.neutral100)
        }
    }

    func configureFilterImage() {
        contentView.backgroundColor = .appColor(.neutral100)
        contentView.layer.cornerRadius = 16
        keyWord.isHidden = true
        filterImageView.isHidden = false
    }
}

extension NoticeKeyWordCollectionViewCell {
    private func setUpLayouts() {
        [keyWord, filterImageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        keyWord.snp.makeConstraints {
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
