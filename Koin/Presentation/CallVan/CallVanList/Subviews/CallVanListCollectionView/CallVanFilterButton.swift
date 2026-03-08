//
//  CallVanFilterButton.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import UIKit

final class CallVanFilterButton: UIButton {
    
    let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        layer.cornerRadius = 17
        layer.borderWidth = 1
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width + 24, height: 34)
    }
    
    override var isSelected: Bool {
        didSet {
            let foregroundColor = isSelected ? UIColor.appColor(.new500) : UIColor.appColor(.neutral500)
            let borderColor = isSelected ? UIColor.appColor(.new500) : UIColor.appColor(.neutral300)
            
            setAttributedTitle(NSAttributedString(string: title, attributes: [
                .font : UIFont.appFont(.pretendardBold, size: 14),
                .foregroundColor : foregroundColor
            ]), for: .normal)
            
            layer.borderColor = borderColor.cgColor
        }
    }
}
