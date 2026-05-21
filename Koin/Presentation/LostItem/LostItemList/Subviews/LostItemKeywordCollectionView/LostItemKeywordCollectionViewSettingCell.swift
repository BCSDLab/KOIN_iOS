//
//  LostItemKeywordCollectionViewSettingCell.swift
//  koin
//
//  Created by 홍기정 on 5/11/26.
//

import UIKit
import SnapKit

final class LostItemKeywordCollectionViewSettingCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let gearImageView = UIImageView(image: UIImage.appImage(asset: .lostItemGear))
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LostItemKeywordCollectionViewSettingCell {
    
    private func configureView() {
        contentView.addSubview(gearImageView)
        gearImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(32)
        }
    }
}
