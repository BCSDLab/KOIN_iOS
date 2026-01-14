//
//  UIApplication.swift
//  koin
//
//  Created by JOOMINKYUNG on 5/8/24.
//

import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController
            { return topViewController(base: selected) }
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    static func hasHomeButton() -> Bool {
        let window = UIApplication.shared
                    .connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }
                guard let safeAreaBottom =  window?.safeAreaInsets.bottom else {
                    return false
                }
                return safeAreaBottom <= 0
    }
    
    static func topSafeAreaHeight() -> CGFloat {
        let height: CGFloat
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let statusBarManager = windowScene?.statusBarManager
        height = statusBarManager?.statusBarFrame.height ?? 0        
        return height
    }
}
