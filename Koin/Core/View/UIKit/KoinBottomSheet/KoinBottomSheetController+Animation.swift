//
//  KoinBottomSheetController+Animation.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

extension KoinBottomSheetController {
    /// 물리 속도는 실제 frame 거리로 정규화한다. 모든 시트 전환이 이 함수를 쓴다.
    func runSpring(
        animated: Bool,
        velocity: CGFloat = 0,
        distance: CGFloat = 0,
        dismissing: Bool = false,
        changes: @escaping () -> Void,
        completion: @escaping () -> Void
    ) {
        guard animated else {
            changes()
            completion()
            return
        }
        let speed = abs(distance) > 0.5 ? velocity / distance : 0
        let timing = UISpringTimingParameters(
            duration: dismissing ? 0.2 : 0.3,
            bounce: dismissing ? 0 : 0.15,
            initialVelocity: CGVector(
                dx: 0,
                dy: speed.isFinite ? speed : 0
            )
        )
        let animation = UIViewPropertyAnimator(
            duration: 0,
            timingParameters: timing
        )
        animator = animation
        animation.addAnimations(changes)
        animation.addCompletion { [weak self, weak animation] position in
            guard let self, self.animator === animation else { return }
            self.animator = nil
            if position == .end {
                completion()
            }
        }
        animation.startAnimation()
    }

    func animateToTarget(
        animated: Bool,
        velocity: CGFloat = 0
    ) {
        let startHeight = sheetView.bounds.height
        let startTransform = containerView.transform
        let startTop = containerView.frame.minY
        let startAlpha = dimView.alpha
        containerView.transform = .identity
        applyTargetHeight()
        view.layoutIfNeeded()
        let targetHeight = sheetView.bounds.height
        let targetTop = containerView.frame.minY
        holdHeight(startHeight)
        containerView.transform = startTransform
        view.layoutIfNeeded()
        dimView.alpha = startAlpha
        runSpring(
            animated: animated,
            velocity: velocity,
            distance: targetTop - startTop
        ) { [weak self] in
            guard let self else { return }
            self.holdHeight(targetHeight)
            self.containerView.transform = .identity
            self.applyModalDimTarget()
            self.view.layoutIfNeeded()
        } completion: { [weak self] in
            guard let self else { return }
            self.applyTargetHeight()
            self.view.layoutIfNeeded()
            self.finishPresentationIfNeeded()
        }
    }

    func capturePresentationLayout() {
        guard let animator else { return }
        let frame = containerView.layer.presentation()?.frame ?? containerView.frame
        let height = sheetView.layer.presentation()?.bounds.height ?? sheetView.bounds.height
        let dimAlpha = dimView.layer.presentation()?.opacity ?? Float(dimView.alpha)
        animator.stopAnimation(true)
        self.animator = nil
        dimView.alpha = CGFloat(dimAlpha)
        holdHeight(height)
        containerView.transform = .identity
        view.layoutIfNeeded()
        containerView.transform = CGAffineTransform(
            translationX: 0,
            y: frame.minY - containerView.frame.minY
        )
    }

    func finishPresentationIfNeeded() {
        guard state == .presenting else { return }
        state = .presented
    }

    func applyModalDimTarget() {
        guard isActive else { return }
        if case let .modal(alpha) = configuration.style {
            dimView.alpha = alpha
        }
    }
}
