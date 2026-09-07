//
//  FilteringButton.swift
//  koin
//
//  Created by 김성민 on 9/6/25.
//

import UIKit

final class FilteringButton: UIButton {

    private var isSelectable: Bool = true
    private var forcedOn: Bool? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.numberOfLines = 1
    
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.contentInsets = .init(top: 6, leading: 8, bottom: 6, trailing: 8)
        config.attributedTitle = AttributedString("필터", attributes: .init([
            .font: UIFont.appFont(.pretendardBold, size: 14)
        ]))

        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = UIColor.appColor(.neutral0)
        background.cornerRadius = 24
        background.strokeWidth = 0.5
        background.strokeColor = UIColor.appColor(.neutral300)
        config.background = background

        config.image = UIImage.appImage(asset: .chevronDown)
        config.baseForegroundColor = UIColor.appColor(.neutral500)

        self.configuration = config

        self.configurationUpdateHandler = { [weak self] button in
            guard let self = self, var config = button.configuration else { return }
            var background = config.background
            let on = self.forcedOn ?? button.isSelected
            if on {
                background.backgroundColor = UIColor.appColor(.new500)
                background.strokeWidth = 0
                background.strokeColor = nil
                config.baseForegroundColor = UIColor.appColor(.neutral0)
            } else {
                background.backgroundColor = UIColor.appColor(.neutral0)
                background.strokeWidth = 0.5
                background.strokeColor = UIColor.appColor(.neutral300)
                config.baseForegroundColor = UIColor.appColor(.neutral500)
            }
            config.background = background
            button.configuration = config
        }

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setTitle(_ text: String) {
        guard var config = configuration else { return }
        config.attributedTitle = AttributedString(text, attributes: .init([
            .font: UIFont.appFont(.pretendardBold, size: 14)
        ]))
        configuration = config
    }

    func set(title: String, iconRight: UIImage? = nil, showsChevron: Bool = false) {
        guard var config = configuration else { return }
        config.attributedTitle = AttributedString(title, attributes: .init([
            .font: UIFont.appFont(.pretendardBold, size: 14)
        ]))
        if showsChevron {
            config.image = UIImage.appImage(asset: .chevronDown)
        } else {
            config.image = iconRight?.withRenderingMode(.alwaysTemplate)
        }
        config.imagePlacement = .trailing
        config.imagePadding = (config.image == nil) ? 0 : 6
        configuration = config
        setNeedsUpdateConfiguration()
    }

    func applyFilter(_ on: Bool) {
        forcedOn = on
        setNeedsUpdateConfiguration()
    }

    func setSelectable(_ selectable: Bool) {
        isSelectable = selectable
    }

    @objc private func handleTap() {
        if isSelectable {
            isSelected.toggle()
            setNeedsUpdateConfiguration()
        }
    }
}

