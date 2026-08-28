//
//  KoinModalPresentationController.swift
//  koin
//
//  Created by 홍기정 on 8/14/26.
//

import UIKit
import Then

final class KoinModalPresentationController: UIPresentationController {
    
    // MARK: - UI Components
    private let dimmingView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
        $0.alpha = 0
    }
    
    // MARK: - Layout
    override var frameOfPresentedViewInContainerView: CGRect {
        containerView?.bounds ?? .zero
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    // MARK: - Present
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView else { return }
        
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        
        guard let transitionCoordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1
            return
        }
        
        transitionCoordinator.animate { [weak self] _ in
            self?.dimmingView.alpha = 1
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    // MARK: - Dismiss
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        guard let transitionCoordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }
        
        transitionCoordinator.animate { [weak self] _ in
            self?.dimmingView.alpha = 0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        if completed {
            dimmingView.removeFromSuperview()
        } else {
            dimmingView.alpha = 1
        }
    }
}
