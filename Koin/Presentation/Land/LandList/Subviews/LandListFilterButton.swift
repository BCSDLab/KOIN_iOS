//
//  LandListFilterButton.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit

final class LandListFilterButton: UIButton {
    enum Style {
        case selected
        case deselected

        var textColor: ColorAsset {
            switch self {
            case .selected: .neutral0
            case .deselected: .new500
            }
        }
        var backgroundColor: ColorAsset {
            switch self {
            case .selected: .new500
            case .deselected: .neutral0
            }
        }
        var borderColor: ColorAsset {
            .new500
        }
    }

    init(title: String) {
        super.init(frame: .zero)
        self.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            let configuration = configuration(title: title, isSelected: button.isSelected)
            self.configuration = configuration
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandListFilterButton {
    private func configuration(title: String, isSelected: Bool) -> UIButton.Configuration {
        let style: Style = isSelected ? .selected : .deselected
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardSemiBold, size: 14),
            .foregroundColor: UIColor.appColor(style.textColor)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 18.5, bottom: 0, trailing: 18.5)
        configuration.background.backgroundColor = .appColor(style.backgroundColor)
        configuration.background.strokeColor = .appColor(style.borderColor)
        configuration.background.strokeWidth = 1
        configuration.cornerStyle = .capsule
        return configuration
    }
}
