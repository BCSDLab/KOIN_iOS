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
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(keyWordModel: NoticeKeyWord, isSelected: Bool) {
        keyWord.text = keyWordModel.keyWord
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
}

extension NoticeKeyWordCollectionViewCell {
    private func setUpLayouts() {
        [keyWord].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        keyWord.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
