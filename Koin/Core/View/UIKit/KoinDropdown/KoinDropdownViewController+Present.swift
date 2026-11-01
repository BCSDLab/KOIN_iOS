//
//  KoinDropdownViewController+Present.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

// MARK: - Present
extension KoinDropdownViewController {
    /// 부모가 child containment(addChild, addSubview, didMove)를 마친 뒤 호출한다.
    func presentDropdown() -> Bool {
        guard let anchor else { return false }
        parent?.view.layoutIfNeeded()
        scrollView = nearestScrollView(to: anchor)

        contentView.transform = .identity
        adjustScrollIfNeeded(animated: true)
        guard layoutPanel() else { return false }
        applyShadow()
        animator.present(
            view: contentView,
            travel: travel
        )
        lastLayoutSize = view.bounds.size
        isPresented = true
        return true
    }
}

// MARK: - Dismiss
extension KoinDropdownViewController {
    func dismissDropdown(animated: Bool = true) {
        guard !isDismissing, !isDismissed else { return }
        isPresented = false
        isDismissing = true

        if animated {
            UIView.animate(withDuration: KoinDropdownAnimator.Metric.dismissDuration) {
                self.restoreScrollView()
            }
            animator.dismiss(
                view: contentView,
                travel: travel
            ) { [weak self] in
                self?.finishDismiss()
            }
        } else {
            contentView.layer.removeAllAnimations()
            restoreScrollView()
            finishDismiss()
        }
    }

    func dismissAfterLayout() {
        DispatchQueue.main.async { [weak self] in
            self?.dismissDropdown(animated: false)
        }
    }

    @objc func handleOutsideTap() {
        dismissDropdown()
    }

    private func finishDismiss() {
        guard !isDismissed else { return }
        isDismissed = true
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
