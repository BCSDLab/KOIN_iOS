//
//  KoinDropdownAnimator.swift
//  koin
//
//  Created by 홍기정 on 8/21/26.
//

import UIKit

@MainActor
final class KoinDropdownAnimator {

    enum Metric {
        static let presentDuration: TimeInterval = 0.3
        static let presentBounce: CGFloat = 0.15
        static let dismissDuration: TimeInterval = 0.15
    }

    private func hiddenTransform(travel: CGFloat) -> CGAffineTransform {
        CGAffineTransform(translationX: 0, y: -travel)
    }

    func present(
        view: UIView,
        travel: CGFloat,
        completion: (() -> Void)? = nil
    ) {
        view.isHidden = false
        view.alpha = 0
        view.transform = hiddenTransform(travel: travel)

        UIView.animate(
            springDuration: Metric.presentDuration,
            bounce: Metric.presentBounce,
            initialSpringVelocity: 0
        ) {
            view.alpha = 1
            view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }

    func dismiss(
        view: UIView,
        travel: CGFloat,
        completion: (() -> Void)? = nil
    ) {
        UIView.animate(
            springDuration: Metric.dismissDuration,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            view.alpha = 0
            view.transform = self.hiddenTransform(travel: travel)
        } completion: { _ in
            view.isHidden = true
            completion?()
        }
    }
}
