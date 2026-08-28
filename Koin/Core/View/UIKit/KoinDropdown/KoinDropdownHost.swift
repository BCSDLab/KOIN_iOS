//
//  KoinDropdownHost.swift
//  koin
//
//  Created by 홍기정 on 8/22/26.
//

import UIKit

@MainActor
final class KoinDropdownHost {

    private enum Metric {
        static let overlayZPosition: CGFloat = 10_000
    }
    
    // MARK: - Properties
    private weak var scrollView: UIScrollView?
    private var overlay: UIView?
    
    private var presentedDropdown: KoinDropdown?
    private var addedBottomInset: CGFloat = 0
    
    var isPresenting: Bool {
        presentedDropdown != nil
    }
    
    // MARK: - Initializer
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }

    // MARK: - Public
    func makeDropdown(
        trigger: UIView,
        contentView: UIView & KoinDropdownContentView,
        configuration: KoinDropdownConfiguration
    ) -> KoinDropdown {
        return KoinDropdown(
            host: self,
            trigger: trigger,
            contentView: contentView,
            configuration: configuration
        )
    }
}

extension KoinDropdownHost {

    // MARK: - Toggle
    func toggle(_ dropdown: KoinDropdown) {
        if presentedDropdown === dropdown {
            dismiss(dropdown)
        } else {
            present(dropdown)
        }
    }

    // MARK: - Present
    func present(_ dropdown: KoinDropdown) {
        guard let scrollView,
              presentedDropdown == nil else {
            return
        }

        scrollView.layoutIfNeeded()

        // 바깥 영역 탭을 인식할 overlay
        let overlay = makeOverlay(in: scrollView, dropdown: dropdown)
        scrollView.addSubview(overlay)
        self.overlay = overlay
        
        // overlay에 들어가는 dropdown
        guard dropdown.layout(in: overlay) else {
            overlay.removeFromSuperview()
            self.overlay = nil
            return
        }
        overlay.addSubview(dropdown)
        self.presentedDropdown = dropdown

        // present 중에는 사용자에 의한 스크롤을 막는다.
        scrollView.isScrollEnabled = false
        
        // present
        addedBottomInset = addBottomInset(
            travel: dropdown.travel,
            of: dropdown,
            in: scrollView
        )
        scrollView.scrollRectToVisible(
            dropdown.convert(dropdown.bounds, to: scrollView),
            animated: true
        )
        dropdown.animatePresent()
    }
    
    // MARK: - Dismiss
    func dismissPresented() {
        guard let presentedDropdown else {
            return
        }
        dismiss(presentedDropdown)
    }
    
    func dismiss(_ dropdown: KoinDropdown) {
        guard presentedDropdown === dropdown else {
            return
        }
        
        let dismissDuration = KoinDropdownAnimator.Metric.dismissDuration
        UIView.animate(withDuration: dismissDuration) { [weak self] in
            self?.scrollView?.contentInset.bottom -= self?.addedBottomInset ?? 0
            self?.addedBottomInset = 0
        }
        
        dropdown.animateDismiss { [weak self] in
            self?.overlay?.removeFromSuperview()
            self?.finishDismiss(of: dropdown)
        }
    }
}

extension KoinDropdownHost {
    private func makeOverlay(
        in scrollView: UIScrollView,
        dropdown: KoinDropdown
    ) -> UIView {
        let scrollableRect = CGRect(origin: .zero, size: scrollView.contentSize)
            .union(CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size))
        
        let overlay = UIView(frame: scrollableRect.insetBy(
            dx: -scrollView.bounds.width,
            dy: -scrollView.bounds.height
        ))
        overlay.backgroundColor = .clear
        overlay.layer.zPosition = Metric.overlayZPosition
        overlay.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleOutsideTap)
            )
        )
        return overlay
    }
    
    @objc private func handleOutsideTap() {
        guard let presentedDropdown else {
            return
        }
        dismiss(presentedDropdown)
    }
}

extension KoinDropdownHost {

    private func addBottomInset(
        travel: CGFloat,
        of dropdown: KoinDropdown,
        in scrollView: UIScrollView
    ) -> CGFloat {
        guard let trigger = dropdown.trigger else {
            return 0
        }
        
        let triggerMaxY = trigger.convert(trigger.bounds, to: scrollView).maxY
        let dropdownMaxY = triggerMaxY + travel
        let viewport = scrollView.bounds.height
        let maxOffsetY = max(
            -scrollView.adjustedContentInset.top,
            scrollView.contentSize.height + scrollView.adjustedContentInset.bottom - viewport
        )
        let reachableBottomY = maxOffsetY + viewport
        let overflow = dropdownMaxY - reachableBottomY
        
        guard 0 < overflow else {
            return 0
        }

        scrollView.contentInset.bottom += overflow
        return overflow
    }

    private func finishDismiss(of dropdown: KoinDropdown) {
        guard presentedDropdown === dropdown else { return }

        presentedDropdown = nil
        overlay = nil
        scrollView?.isScrollEnabled = true
    }
}
