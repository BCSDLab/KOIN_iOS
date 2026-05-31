//
//  UIImage+.swift
//  Koin
//
//  Created by 김나훈 on 1/15/24.
//

import UIKit.UIImage

extension UIImage {
    static func appImage(asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
    
    static func appImage(symbol: SFSymbols) -> UIImage? {
        return UIImage(systemName: symbol.rawValue)
    }
    
    func resize(to size: CGSize) -> UIImage? {
        return UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
