//
//  Font+.swift
//  Koin
//
//  Created by 홍기정 on 5/31/26.
//

import SwiftUI

extension Font {
    static func appFont(_ asset: FontAsset, size: Int) -> Font {
        return .custom(asset.rawValue, size: CGFloat(size))
    }
}
