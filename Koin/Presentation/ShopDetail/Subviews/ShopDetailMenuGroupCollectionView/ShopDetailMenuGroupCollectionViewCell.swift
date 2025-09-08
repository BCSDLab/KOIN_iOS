//
//  ShopDetailMenuGroupCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/8/25.
//

import UIKit
import SnapKit

class ShopDetailMenuGroupCollectionViewCell: UICollectionViewCell {
    
    let label = UILabel().then {
        $0.font = .appFont(.pretendardSemiBold, size: 14)
        $0.textColor = .appColor(.neutral400)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShopDetailMenuGroupCollectionViewCell {
    
    func bind(_ text: String){
        label.text = text
    }
    
    private func configureView() {
        layer.cornerRadius = 17
        backgroundColor = .appColor(.neutral0)
        
        [label].forEach {
            addSubview($0)
        }
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
