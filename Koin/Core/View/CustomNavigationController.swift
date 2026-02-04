//
//  CustomNavigationController.swift
//  koin
//
//  Created by 김나훈 on 5/20/24.
//

import UIKit

class CustomNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

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
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
