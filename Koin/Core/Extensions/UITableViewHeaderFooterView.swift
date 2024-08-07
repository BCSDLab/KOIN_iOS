//
//  UITableViewHeaderFooterView.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/28/24.
//

import UIKit

extension UITableViewHeaderFooterView {
    static var identifier: String {
        return String(describing: type(of: self))
    }
}
