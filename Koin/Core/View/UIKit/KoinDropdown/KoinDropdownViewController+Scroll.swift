//
//  KoinDropdownViewController+Scroll.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

// MARK: - Scroll
extension KoinDropdownViewController {
    func nearestScrollView(to anchor: UIView) -> UIScrollView? {
        var ancestor = anchor.superview
        while let current = ancestor {
            if let scrollView = current as? UIScrollView, scrollView.isScrollEnabled {
                return scrollView
            }
            ancestor = current.superview
        }
        return nil
    }

    /// 스크롤을 잠그고 필요한 하단 inset을 추가한 뒤, anchor와 dropdown이 보이도록 offset을 조정한다.
    func adjustScrollIfNeeded(animated: Bool) {
        guard let anchor else { return }
        travel = contentView.height + configuration.topPadding

        guard let scrollView else { return }
        scrollView.isScrollEnabled = false
        scrollView.contentInset.bottom -= addedBottomInset
        addedBottomInset = 0
        scrollView.layoutIfNeeded()
        addedBottomInset = addBottomInset(
            anchor: anchor,
            in: scrollView
        )

        let anchorFrame = anchor.convert(anchor.bounds, to: scrollView)
        let dropdownBottomY = anchorFrame.maxY + travel + configuration.shadowPadding.bottom
        let minOffsetY = -scrollView.adjustedContentInset.top
        let maximumOffsetY = maxOffsetY(of: scrollView)
        let bottomVisibleOffsetY = dropdownBottomY - scrollView.bounds.height
        let topVisibleOffsetY = anchorFrame.minY - scrollView.adjustedContentInset.top
        // anchor와 dropdown을 합친 높이가 화면보다 크면 anchor가 보이는 쪽을 우선한다.
        let targetOffsetY = min(maximumOffsetY, max(minOffsetY, min(
            topVisibleOffsetY,
            max(scrollView.contentOffset.y, bottomVisibleOffsetY)
        )))
        let targetOffset = CGPoint(x: scrollView.contentOffset.x, y: targetOffsetY)
        if animated {
            UIView.animate(withDuration: KoinDropdownAnimator.Metric.presentDuration) {
                scrollView.contentOffset = targetOffset
            }
        } else {
            scrollView.contentOffset = targetOffset
        }
    }

    func restoreScrollView() {
        if let scrollView {
            scrollView.contentInset.bottom -= addedBottomInset
            scrollView.contentOffset = CGPoint(
                x: scrollView.contentOffset.x,
                y: min(scrollView.contentOffset.y, maxOffsetY(of: scrollView))
            )
        }
        addedBottomInset = 0
        scrollView?.isScrollEnabled = true
    }

    private func addBottomInset(
        anchor: UIView,
        in scrollView: UIScrollView
    ) -> CGFloat {
        let dropdownMaxY = anchor.convert(anchor.bounds, to: scrollView).maxY + travel + configuration.shadowPadding.bottom
        let viewport = scrollView.bounds.height
        let overflow = dropdownMaxY - (maxOffsetY(of: scrollView) + viewport)
        guard overflow > 0 else { return 0 }
        scrollView.contentInset.bottom += overflow
        return overflow
    }

    private func maxOffsetY(of scrollView: UIScrollView) -> CGFloat {
        max(
            -scrollView.adjustedContentInset.top,
            scrollView.contentSize.height + scrollView.adjustedContentInset.bottom - scrollView.bounds.height
        )
    }
}
