//
//  Image+.swift
//  Koin
//
//  Created by Claude on 5/31/26.
//

import SwiftUI

extension Image {
    static func appImage(asset: ImageAsset) -> Image {
        return Image(asset.rawValue)
    }

    static func appImage(symbol: SFSymbols) -> Image {
        return Image(systemName: symbol.rawValue)
    }
}
