//
//  StatefulButton.swift
//  koin
//
//  Created by 이은지 on 6/5/25.
//

import UIKit

final class StatefulButton: UIButton {

    private var enabledColor: UIColor = UIColor.appColor(.primary500)
    private var disabledColor: UIColor = UIColor.appColor(.neutral300)
    private var enabledTextColor: UIColor = .white
    private var disabledTextColor: UIColor = UIColor.appColor(.neutral800)

    init(title: String,
         font: UIFont = UIFont.appFont(.pretendardMedium, size: 10),
         enabledColor: UIColor,
         disabledColor: UIColor = UIColor.appColor(.neutral300),
         enabledTextColor: UIColor = .white,
         disabledTextColor: UIColor = UIColor.appColor(.neutral800),
         cornerRadius: CGFloat = 4) {
        super.init(frame: .zero)
        self.enabledColor = enabledColor
        self.disabledColor = disabledColor
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        updateState(isEnabled: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateState(isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.backgroundColor = isEnabled ? enabledColor : disabledColor
        self.setTitleColor(isEnabled ? enabledTextColor : disabledTextColor, for: .normal)
    }
}
