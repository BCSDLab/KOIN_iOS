//
//  CustomNavigationController.swift
//  koin
//
//  Created by 김나훈 on 5/20/24.
//

import UIKit

protocol InteractivePopGestureHandler: AnyObject {
    func shouldBeginInteractivePopGesture() -> Bool
}

final class CustomNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        interactivePopGestureRecognizer?.delegate = self
        if #available(iOS 26.0, *) {
            interactiveContentPopGestureRecognizer?.delegate = self
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard isInteractivePopGesture(gestureRecognizer) else { return true }
        guard viewControllers.count > 1, transitionCoordinator == nil else { return false }
        guard !children.contains(where: { $0 is KoinBottomSheetController }) else { return false }
        return (topViewController as? InteractivePopGestureHandler)?.shouldBeginInteractivePopGesture() ?? true
    }
    
    private func isInteractivePopGesture(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === interactivePopGestureRecognizer {
            return true
        }
        if #available(iOS 26.0, *) {
            return gestureRecognizer === interactiveContentPopGestureRecognizer
        }
        return false
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let transitionCoordinator = navigationController.transitionCoordinator,
              let fromVC = transitionCoordinator.viewController(forKey: .from) else {
            return
        }
        let isPop = !navigationController.viewControllers.contains(fromVC)
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
