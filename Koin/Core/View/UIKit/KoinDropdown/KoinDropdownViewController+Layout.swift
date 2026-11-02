//
//  KoinDropdownViewController+Layout.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

// MARK: - Layout
extension KoinDropdownViewController {
    /// 화면의 안전 영역에서 그림자까지 들어가는 방향을 정한다. 양쪽 모두 부족하면 더 넓은 쪽을 고른다.
    func resolveDirection() {
        guard configuration.direction == .auto else {
            resolvedDirection = .down
            fitsInResolvedDirection = false
            return
        }
        guard let anchor else { return }
        anchor.layoutIfNeeded()
        let anchorFrame = anchor.convert(anchor.bounds, to: view)
        let visible = view.bounds.inset(by: view.safeAreaInsets)
        let spaceBelow = visible.maxY - anchorFrame.maxY
        let spaceAbove = anchorFrame.minY - visible.minY
        let requiredHeight = contentView.height + configuration.topPadding
        let fitsBelow = requiredHeight + configuration.shadowPadding(for: .down).bottom <= spaceBelow
        let fitsAbove = requiredHeight + configuration.shadowPadding(for: .up).top <= spaceAbove

        if fitsBelow {
            resolvedDirection = .down
            fitsInResolvedDirection = true
        } else if fitsAbove {
            resolvedDirection = .up
            fitsInResolvedDirection = true
        } else {
            resolvedDirection = spaceBelow >= spaceAbove ? .down : .up
            fitsInResolvedDirection = false
        }
    }

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
        let padding = configuration.shadowPadding(for: resolvedDirection)
        switch resolvedDirection {
        case .down:
            panel.frame = CGRect(
                x: anchorFrame.minX - padding.left,
                y: anchorFrame.maxY,
                width: anchorFrame.width + padding.left + padding.right,
                height: travel + padding.bottom
            )
        case .up:
            panel.frame = CGRect(
                x: anchorFrame.minX - padding.left,
                y: anchorFrame.minY - travel - padding.top,
                width: anchorFrame.width + padding.left + padding.right,
                height: travel + padding.top
            )
        }
        contentView.bounds = CGRect(
            origin: .zero,
            size: CGSize(width: anchorFrame.width, height: panelHeight)
        )
        contentView.center = CGPoint(
            x: padding.left + anchorFrame.width / 2,
            y: (resolvedDirection == .down ? configuration.topPadding : padding.top) + panelHeight / 2
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
