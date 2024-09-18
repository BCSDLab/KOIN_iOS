//
//  UIViewController+.swift
//  Koin
//
//  Created by 김나훈 on 3/13/24.
//

import UIKit.UIViewController

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showIndicator() {
        IndicatorView.shared.show()
    }
    
    func dismissIndicator() {
        IndicatorView.shared.dismiss()
    }
}

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
