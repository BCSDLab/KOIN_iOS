//
//  KoinDropdownViewController+Scroll.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

// MARK: - Scroll
extension KoinDropdownViewController {
    /// 아래 고정은 기존대로 조정하고, 자동 방향은 아래 공간이 부족할 때만 조정한다.
    func prepareScrollIfNeeded() -> CGPoint? {
        switch configuration.direction {
        case .down:
            return prepareScroll()
        case .auto:
            if resolvedDirection == .down, !fitsInResolvedDirection {
                return prepareScroll()
            }
            if isScrollPrepared {
                restoreScrollView()
            }
            return nil
        }
    }

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

    /// 필요한 하단 inset을 추가한 뒤, anchor와 dropdown이 보이는 목표 offset을 반환한다. 바깥 스크롤은 드롭다운을 닫으므로 스크롤을 잠그지 않는다.
    func prepareScroll() -> CGPoint? {
        guard let anchor else { return nil }
        travel = contentView.height + configuration.spacing(for: .down)

        guard let scrollView else { return nil }
        isScrollPrepared = true
        scrollView.contentInset.bottom -= addedBottomInset
        addedBottomInset = 0
        scrollView.layoutIfNeeded()
        addedBottomInset = addBottomInset(
            anchor: anchor,
            in: scrollView
        )

        let anchorFrame = anchor.convert(anchor.bounds, to: scrollView)
        let dropdownBottomY = anchorFrame.maxY + travel + configuration.shadowPadding(for: .down).bottom
        let minOffsetY = -scrollView.adjustedContentInset.top
        let maximumOffsetY = maxOffsetY(of: scrollView)
        let bottomVisibleOffsetY = dropdownBottomY - scrollView.bounds.height
        let topVisibleOffsetY = anchorFrame.minY - scrollView.adjustedContentInset.top
        // anchor와 dropdown을 합친 높이가 화면보다 크면 anchor가 보이는 쪽을 우선한다.
        let targetOffsetY = min(maximumOffsetY, max(minOffsetY, min(
            topVisibleOffsetY,
            max(scrollView.contentOffset.y, bottomVisibleOffsetY)
        )))
        return CGPoint(x: scrollView.contentOffset.x, y: targetOffsetY)
    }

    func restoreScrollView() {
        // 조정한 스크롤만 원복한다.
        guard isScrollPrepared else { return }
        if let scrollView {
            scrollView.contentInset.bottom -= addedBottomInset
            // 바깥 스크롤로 닫히는 중이면 손가락 드래그와 다투지 않게 위치는 스크롤뷰에 맡긴다.
            if !scrollView.isTracking {
                scrollView.contentOffset = CGPoint(
                    x: scrollView.contentOffset.x,
                    y: min(scrollView.contentOffset.y, maxOffsetY(of: scrollView))
                )
            }
        }
        addedBottomInset = 0
        isScrollPrepared = false
    }

    private func addBottomInset(
        anchor: UIView,
        in scrollView: UIScrollView
    ) -> CGFloat {
        let dropdownMaxY = anchor.convert(anchor.bounds, to: scrollView).maxY + travel + configuration.shadowPadding(for: .down).bottom
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
