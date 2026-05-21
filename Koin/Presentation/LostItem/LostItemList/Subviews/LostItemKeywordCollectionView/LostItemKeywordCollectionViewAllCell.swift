//
//  LostItemKeywordCollectionViewAllCell.swift
//  koin
//
//  Created by 홍기정 on 5/11/26.
//

import UIKit
import SnapKit

final class LostItemKeywordCollectionViewAllCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let allLabel = UILabel().then {
        $0.text = "새 키워드 추가"
        $0.contentMode = .center
        $0.textAlignment = .center
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral500)
        $0.backgroundColor = .appColor(.neutral100)
    }
    
    // MARK: - Initialzier
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LostItemKeywordCollectionViewAllCell {
    
    private func configureView() {
        contentView.addSubview(allLabel)
        allLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
