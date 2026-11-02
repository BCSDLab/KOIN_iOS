//
//  UIViewController+Dropdown.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

// MARK: - UIViewController
extension UIViewController {
    var isPresentingDropdown: Bool {
        children.contains(where: { $0 is KoinDropdownViewController })
    }

    @discardableResult
    func presentDropdown(
        anchor: UIView,
        content: UIView & KoinDropdownContentView,
        configuration: KoinDropdownConfiguration
    ) -> KoinDropdownViewController? {
        guard !isPresentingDropdown,
              anchor.isDescendant(of: view) else { return nil }

        view.endEditing(true)
        let dropdown = KoinDropdownViewController(
            anchor: anchor,
            contentView: content,
            configuration: configuration
        )
        addChild(dropdown)
        dropdown.view.frame = view.bounds
        view.addSubview(dropdown.view)
        dropdown.didMove(toParent: self)
        guard dropdown.presentDropdown() else {
            dropdown.dismissDropdown(animated: false)
            return nil
        }
        return dropdown
    }
}

// MARK: - UIView
extension UIView {
    @discardableResult
    func presentDropdown(
        anchor: UIView,
        content: UIView & KoinDropdownContentView,
        configuration: KoinDropdownConfiguration
    ) -> KoinDropdownViewController? {
        // responder chain을 따라 올라가 이 view를 띄운 가장 가까운 VC를 찾는다.
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController.presentDropdown(
                    anchor: anchor,
                    content: content,
                    configuration: configuration
                )
            }
            responder = current.next
        }
        return nil
    }
}
