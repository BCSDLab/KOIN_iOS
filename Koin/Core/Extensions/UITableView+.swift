//
//  UITableView+.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import UIKit

extension UITableView {
    func calculateDynamicHeight() -> CGFloat {
        self.layoutIfNeeded()
        return self.contentSize.height
    }
}
