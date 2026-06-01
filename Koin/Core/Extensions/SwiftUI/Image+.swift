//
//  Image+.swift
//  Koin
//
//  Created by Claude on 5/31/26.
//

import SwiftUI

extension SwiftUI.Image {
    static func appImage(asset: ImageAsset) -> SwiftUI.Image {
        return SwiftUI.Image(asset.rawValue)
    }

    static func appImage(symbol: SFSymbols) -> SwiftUI.Image {
        return SwiftUI.Image(systemName: symbol.rawValue)
    }
}
