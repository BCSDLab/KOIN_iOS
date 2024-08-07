//
//  UIViewcontroller.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/03/31.
//

import UIKit
import SnapKit

extension UIViewController {
    
    func dismissView() {
        self.dismiss(animated: true)
    }
    //UIAction
    func presentActionSheet(title: String, message: String? = nil,
                      isCancelActionIncluded: Bool = false,
                      preferredStyle style: UIAlertController.Style = .actionSheet,
                      with actions: [UIAlertAction]) {
    
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { actionSheet.addAction($0) }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapBackgroundBtn))
        actionSheet.view.superview?.subviews[0].addGestureRecognizer(tap)  // FIXME-UIAlertController 계층구조

        if isCancelActionIncluded {
            let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            actionSheet.addAction(actionCancel)
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func tapBackgroundBtn() {
        self.dismiss(animated: true)
    }
    
}
