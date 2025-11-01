//
//  ShopSummaryMenuGroupCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/8/25.
//

import UIKit
import SnapKit

final class ShopSummaryMenuGroupCollectionViewCell: UICollectionViewCell {
    
    private let label = UILabel().then {
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
    
    func configure(_ text: String){
        label.text = text
    }
}

extension ShopSummaryMenuGroupCollectionViewCell {
    
    func setSelected(isSelected: Bool){
        label.textColor = isSelected ? .appColor(.new500) : .appColor(.neutral400)
        layer.borderColor = isSelected ? UIColor.appColor(.new500).cgColor : .none
        layer.borderWidth = isSelected ? 1 : 0
        layer.applySketchShadow(color: isSelected ? .clear : .appColor(.neutral800),
                                alpha: 0.04, x: 0, y: 1, blur: 1, spread: 0)
        layer.shadowRadius = 17
    }
}

extension ShopSummaryMenuGroupCollectionViewCell {
    
    private func configureView() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 17
        layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.01, x: 0, y: 1, blur: 1, spread: 0)
        layer.shadowRadius = 17
        
        addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
