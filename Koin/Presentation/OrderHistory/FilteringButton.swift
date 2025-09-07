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
    
        var cf = UIButton.Configuration.plain()
        cf.imagePlacement = .trailing
        cf.imagePadding = 6
        cf.contentInsets = .init(top: 6, leading: 8, bottom: 6, trailing: 8)
        cf.attributedTitle = AttributedString("필터", attributes: .init([
            .font: UIFont.appFont(.pretendardBold, size: 14)
        ]))

        var bg = UIBackgroundConfiguration.clear()
        bg.backgroundColor = UIColor.appColor(.neutral0)
        bg.cornerRadius = 24
        bg.strokeWidth = 0.5
        bg.strokeColor = UIColor.appColor(.neutral300)
        cf.background = bg

        cf.image = UIImage.appImage(asset: .chevronDown)
        cf.baseForegroundColor = UIColor.appColor(.neutral500)

        self.configuration = cf

        self.configurationUpdateHandler = { [weak self] button in
            guard let self = self, var cfg = button.configuration else { return }
            var bg = cfg.background
            let on = self.forcedOn ?? button.isSelected
            if on {
                bg.backgroundColor = UIColor.appColor(.new500)
                bg.strokeWidth = 0
                bg.strokeColor = nil
                cfg.baseForegroundColor = UIColor.appColor(.neutral0)
            } else {
                bg.backgroundColor = UIColor.appColor(.neutral0)
                bg.strokeWidth = 0.5
                bg.strokeColor = UIColor.appColor(.neutral300)
                cfg.baseForegroundColor = UIColor.appColor(.neutral500)
            }
            cfg.background = bg
            button.configuration = cfg
        }

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setTitle(_ text: String) {
        guard var cfg = configuration else { return }
        cfg.attributedTitle = AttributedString(text, attributes: .init([
            .font: UIFont.appFont(.pretendardBold, size: 14)
        ]))
        configuration = cfg
    }

    func set(title: String, iconRight: UIImage? = nil, showsChevron: Bool = false) {
        guard var cfg = configuration else { return }
        cfg.attributedTitle = AttributedString(title, attributes: .init([
            .font: UIFont.appFont(.pretendardBold, size: 14)
        ]))
        if showsChevron {
            cfg.image = UIImage.appImage(asset: .chevronDown)
        } else {
            cfg.image = iconRight?.withRenderingMode(.alwaysTemplate)
        }
        cfg.imagePlacement = .trailing
        cfg.imagePadding = (cfg.image == nil) ? 0 : 6
        configuration = cfg
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
