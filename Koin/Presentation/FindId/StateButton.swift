//
//  StateButton.swift
//  koin
//
//  Created by 김나훈 on 6/17/25.
//

import UIKit

final class StateButton: UIButton {
    
    enum State {
        case unusable
        case usable
        case retry
    }
    
    init(title: String? = nil, font: UIFont = UIFont.appFont(.pretendardRegular, size: 10), titleColor: UIColor = UIColor.appColor(.neutral600), backgroundColor: UIColor = UIColor.appColor(.neutral300)) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = font
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 4
    }
    
    func setState(state: State) {
        switch state {
        case .unusable:
            self.backgroundColor = UIColor.appColor(.neutral200)
            self.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        case .usable:
            self.backgroundColor = UIColor.appColor(.primary500)
            self.setTitleColor(.white, for: .normal)
        case .retry:
            self.backgroundColor = UIColor.appColor(.sub500)
            self.setTitleColor(.white, for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
