//
//  UIViewController+isOnScreen.swift
//  koin
//
//  Created by 홍기정 on 1/9/26.
//

import UIKit

extension UIViewController {
    
    var isOnScreen: Bool {
        viewIfLoaded?.window != nil
    }
}
