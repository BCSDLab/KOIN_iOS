//
//  UICollectionViewCell+.swift
//  Koin
//
//  Created by 김나훈 on 1/21/24.
//

import UIKit.UICollectionViewCell

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: type(of: self))
    }
}

