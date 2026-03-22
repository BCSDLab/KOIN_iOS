//
//  CustomNavigationController.swift
//  koin
//
//  Created by 김나훈 on 5/20/24.
//

import UIKit

class CustomNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    var didSwipeToPop = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(didRecognizePopGesture))
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        didSwipeToPop = false
        
        guard let interactivePopGestureRecognizer = self.interactivePopGestureRecognizer else { return }
        if viewControllers.count > 1 {
            interactivePopGestureRecognizer.isEnabled = true
        } else {
            interactivePopGestureRecognizer.isEnabled = false
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationController.transitionCoordinator?.notifyWhenInteractionChanges { [weak self] context in
            if context.isCancelled {
                self?.didSwipeToPop = false
            }
        }
    }

    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    @objc private func didRecognizePopGesture() {
        switch interactivePopGestureRecognizer?.state {
        case .began:
            didSwipeToPop = true
        default:
            break
        }
    }
}
