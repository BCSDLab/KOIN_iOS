//
//  CallVanButton.swift
//  koin
//
//  Created by 홍기정 on 3/3/26.
//

import UIKit

final class CallVanButton: UIButton {
    
    init() {
        super.init(frame: .zero)
    }
    
    func configure(state: CallVanState) {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(
            state.rawValue,
            attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor : state.foregroundColor
            ])
        )
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: state.inset, bottom: 0, trailing: state.inset)
        self.configuration = configuration
        
        backgroundColor = state.backgroundColor
        layer.cornerRadius = 4
        
        if let borderColor = state.borderColor {
            layer.borderWidth = 1
            layer.borderColor = borderColor.cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let contentSize = super.intrinsicContentSize
        return CGSize(width: contentSize.width, height: 30)
    }
}
