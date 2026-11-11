//
//  KoinDropdownAnimator.swift
//  koin
//
//  Created by 홍기정 on 8/21/26.
//

import UIKit

@MainActor
final class KoinDropdownAnimator {

    // MARK: - Metric
    enum Metric {
        static let presentDuration: TimeInterval = 0.3
        static let presentBounce: CGFloat = 0.15
        static let dismissDuration: TimeInterval = 0.2
    }

    // MARK: - Transform
    private func hiddenTransform(hiddenOffsetY: CGFloat) -> CGAffineTransform {
        CGAffineTransform(
            translationX: 0,
            y: hiddenOffsetY
        )
    }

    // MARK: - Present
    func present(
        view: UIView,
        hiddenOffsetY: CGFloat,
        completion: (() -> Void)? = nil
    ) {
        view.isHidden = false
        view.alpha = 0
        view.transform = hiddenTransform(hiddenOffsetY: hiddenOffsetY)

        UIView.animate(
            springDuration: Metric.presentDuration,
            bounce: Metric.presentBounce
        ) {
            view.alpha = 1
            view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }

    // MARK: - Dismiss
    func dismiss(
        view: UIView,
        hiddenOffsetY: CGFloat,
        completion: (() -> Void)? = nil
    ) {
        UIView.animate(springDuration: Metric.dismissDuration) {
            view.alpha = 0
            view.transform = self.hiddenTransform(hiddenOffsetY: hiddenOffsetY)
        } completion: { _ in
            view.isHidden = true
            completion?()
        }
    }
}
