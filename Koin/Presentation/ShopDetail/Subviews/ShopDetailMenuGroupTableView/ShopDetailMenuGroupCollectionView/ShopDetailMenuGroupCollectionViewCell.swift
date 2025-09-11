//
//  ShopDetailMenuGroupCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/8/25.
//

import UIKit
import SnapKit

final class ShopDetailMenuGroupCollectionViewCell: UICollectionViewCell {
    
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
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 17
        layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.01, x: 0, y: 1, blur: 1, spread: 0)
        layer.shadowRadius = 17
        
        [label].forEach {
            addSubview($0)
        }
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
