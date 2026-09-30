//
//  KoinModalAnimator.swift
//  koin
//
//  Created by 홍기정 on 8/14/26.
//

import UIKit

final class KoinModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TransitionType {
        case present
        case dismiss
    }
    
    // MARK: - Properties
    private let duration: TimeInterval = 0.2
    private let deflatedTransition = CGAffineTransform(scaleX: 0.9, y: 0.9)
    private let transitionType: TransitionType
    
    // MARK: - Initializer
    init(transitionType: TransitionType) {
        self.transitionType = transitionType
    }
    
    // MARK: - Transition
    func transitionDuration(
        using transitionContext: (any UIViewControllerContextTransitioning)?
    ) -> TimeInterval {
        duration
    }
    
    func animateTransition(
        using transitionContext: any UIViewControllerContextTransitioning
    ) {
        switch transitionType {
        case .present:
            animatePresentation(using: transitionContext)
        case .dismiss:
            animateDismissal(using: transitionContext)
        }
    }
    
    private func animatePresentation(
        using transitionContext: any UIViewControllerContextTransitioning
    ) {
        guard
            let presentedViewController = transitionContext.viewController(forKey: .to),
            let presentedView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        presentedView.frame = transitionContext.finalFrame(for: presentedViewController)
        containerView.addSubview(presentedView)
        
        presentedView.alpha = 0
        presentedView.transform = deflatedTransition
        
        UIView.animate(springDuration: duration) {
            presentedView.alpha = 1
            presentedView.transform = .identity
        } completion: { _ in
            let didComplete = !transitionContext.transitionWasCancelled
            if !didComplete {
                presentedView.removeFromSuperview()
            }
            transitionContext.completeTransition(didComplete)
        }
    }
    
    private func animateDismissal(
        using transitionContext: any UIViewControllerContextTransitioning
    ) {
        guard let presentedView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        
        UIView.animate(springDuration: duration) {
            presentedView.alpha = 0
            presentedView.transform = self.deflatedTransition
        } completion: { _ in
            let didComplete = !transitionContext.transitionWasCancelled
            if !didComplete {
                presentedView.alpha = 1
                presentedView.transform = .identity
            }
            transitionContext.completeTransition(didComplete)
        }
    }
}
