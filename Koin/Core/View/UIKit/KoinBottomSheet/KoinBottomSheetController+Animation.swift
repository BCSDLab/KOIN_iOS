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
        // 키보드를 닫으며 끈 뒤에는 콘텐츠가 시트 하단에서 떠 있다. 그 간격에서 시작해 0으로 맞춘다.
        let startContentInset = startHeight - contentViewController.view.frame.maxY
        let startTransform = containerView.transform
        let startTop = containerView.frame.minY
        let startAlpha = dimView.alpha
        containerView.transform = .identity
        applyTargetHeight()
        view.layoutIfNeeded()
        let targetHeight = sheetView.bounds.height
        let targetTop = containerView.frame.minY
        holdHeight(startHeight)
        contentBottomConstraint?.update(inset: startContentInset)
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
            self.contentBottomConstraint?.update(inset: 0)
            self.containerView.transform = .identity
            self.applyDimTarget()
            self.view.layoutIfNeeded()
            self.notifyTargetFrame()
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
        let contentMaxY = contentViewController.view.layer.presentation()?.frame.maxY ?? contentViewController.view.frame.maxY
        let dimAlpha = dimView.layer.presentation()?.opacity ?? Float(dimView.alpha)
        animator.stopAnimation(true)
        self.animator = nil
        dimView.alpha = CGFloat(dimAlpha)
        holdHeight(height)
        contentBottomConstraint?.update(inset: max(0, height - contentMaxY))
        containerView.transform = .identity
        view.layoutIfNeeded()
        containerView.transform = CGAffineTransform(
            translationX: 0,
            y: frame.minY - containerView.frame.minY
        )
    }

    /// transform이 identity인 목표 레이아웃에서 불러야 최종 frame이 나간다.
    func notifyTargetFrame() {
        guard isActive else { return }
        configuration.onTargetFrameChange?(sheetView.convert(sheetView.bounds, to: nil))
    }

    func finishPresentationIfNeeded() {
        guard state == .presenting else { return }
        state = .presented
    }

    func applyDimTarget() {
        guard isActive else { return }
        switch configuration.style {
        case let .modal(alpha):
            dimView.alpha = alpha
        case .nonModal:
            dimView.alpha = isFullScreen ? Self.nonModalFullScreenDimAlpha : 0
        }
    }

    /// nonModal을 끌 때 기본 높이에서 fullscreen으로 갈수록 dim을 진하게 한다.
    func applyNonModalDim(forHeight height: CGFloat, baseHeight: CGFloat) {
        guard !isModal else { return }
        let range = availableHeight - baseHeight
        let progress = range > 0.5 ? (height - baseHeight) / range : (isFullScreen ? 1 : 0)
        dimView.alpha = Self.nonModalFullScreenDimAlpha * min(1, max(0, progress))
    }
}
