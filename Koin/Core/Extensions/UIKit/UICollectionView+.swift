//
//  UICollectionView+.swift
//  koin
//
//  Created by 김나훈 on 4/10/24.
//

import UIKit

extension UICollectionView {
    func calculateDynamicHeight() -> CGFloat {
        self.layoutIfNeeded()
        return self.contentSize.height
    }
}
