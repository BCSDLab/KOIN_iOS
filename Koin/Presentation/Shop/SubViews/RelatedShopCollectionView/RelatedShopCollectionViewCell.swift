//
//  RelatedShopCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/14/24.
//

import Combine
import UIKit

final class RelatedShopCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(info: Keyword) {
        
        
    }
}

extension RelatedShopCollectionViewCell {
    private func setUpLayouts() {
        [].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
    }
    
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

