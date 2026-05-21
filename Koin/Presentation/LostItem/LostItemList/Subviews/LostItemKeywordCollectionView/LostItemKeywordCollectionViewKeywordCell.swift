//
//  LostItemKeywordCollectionViewKeywordCell.swift
//  koin
//
//  Created by 홍기정 on 5/11/26.
//

import UIKit
import SnapKit

final class LostItemKeywordCollectionViewKeywordCell: UICollectionViewCell {
    
    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            keywordLabel.font = font
            keywordLabel.textColor = textColor
            keywordLabel.backgroundColor = chipColor
        }
    }
    
    var font: UIFont? {
        switch isSelected {
        case true:
            UIFont.appFont(.pretendardSemiBold, size: 14)
        case false:
            UIFont.appFont(.pretendardMedium, size: 14)
        }
    }
    
    private var textColor: UIColor? {
        switch isSelected {
        case true:
            UIColor.white
        case false:
            UIColor.appColor(.neutral500)
        }
    }
    
    private var chipColor: UIColor? {
        switch isSelected {
        case true:
            UIColor.appColor(.primary500)
        case false:
            UIColor.appColor(.neutral100)
        }
    }
    
    // MARK: - UI Components
    private let keywordLabel = UILabel().then {
        $0.contentMode = .center
        $0.textAlignment = .center
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
    }
    
    // MARK: - Initialzier
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(keyword: String) {
        keywordLabel.text = keyword
        isSelected = false
    }
}

extension LostItemKeywordCollectionViewKeywordCell {
    
    private func configureView() {
        contentView.addSubview(keywordLabel)
        keywordLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
