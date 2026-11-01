//
//  KoinDropdownViewController+Layout.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

// MARK: - Layout
extension KoinDropdownViewController {
    /// anchor의 현재 위치를 기준으로 panel과 contentView를 배치한다. 배치할 수 없으면 dismiss를 예약하고 false를 반환한다.
    @discardableResult
    func layoutPanel() -> Bool {
        guard let anchor else {
            dismissAfterLayout()
            return false
        }
        anchor.layoutIfNeeded()
        let panelHeight = contentView.height
        guard anchor.window != nil, anchor.bounds.width > 0, panelHeight > 0 else {
            dismissAfterLayout()
            return false
        }

        travel = panelHeight + configuration.topPadding
        let anchorFrame = anchor.convert(anchor.bounds, to: view)
        let padding = configuration.shadowPadding
        panel.frame = CGRect(
            x: anchorFrame.minX - padding.left,
            y: anchorFrame.maxY,
            width: anchorFrame.width + padding.left + padding.right,
            height: travel + padding.bottom
        )
        contentView.bounds = CGRect(
            origin: .zero,
            size: CGSize(width: anchorFrame.width, height: panelHeight)
        )
        contentView.center = CGPoint(
            x: padding.left + anchorFrame.width / 2,
            y: configuration.topPadding + panelHeight / 2
        )
        return true
    }

    func applyShadow() {
        let shadow = configuration.shadow
        contentView.layer.applySketchShadow(
            color: UIColor.appColor(shadow.color),
            alpha: shadow.alpha,
            x: shadow.offset.x,
            y: shadow.offset.y,
            blur: shadow.blur,
            spread: shadow.spread
        )
    }
}
