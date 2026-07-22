//
//  CustomNavigationController.swift
//  koin
//
//  Created by 김나훈 on 5/20/24.
//

import UIKit

final class CustomNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let interactivePopGestureRecognizer = self.interactivePopGestureRecognizer else { return }
        if viewControllers.count > 1 {
            interactivePopGestureRecognizer.isEnabled = true
        } else {
            interactivePopGestureRecognizer.isEnabled = false
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let transitionCoordinator = navigationController.transitionCoordinator,
              let fromVC = transitionCoordinator.viewController(forKey: .from),
              let toVC = transitionCoordinator.viewController(forKey: .to) else {
            return
        }
        let isPop = navigationController.viewControllers.contains(toVC)
        let isSwipe = transitionCoordinator.isInteractive
        
        if isPop, let loggableVC = fromVC as? PopLoggable {
            transitionCoordinator.animate(alongsideTransition: nil) { _ in
                // 사용자가 스와이프를 취소하지 않고 화면이 완전히 사라졌을 때만 실행
                if !transitionCoordinator.isCancelled {
                    let category: EventParameter.EventCategory = isSwipe ? .swipe : .click
                    loggableVC.sendPopLog(category: category)
                }
            }
        }
    }

    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
