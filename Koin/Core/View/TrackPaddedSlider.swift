//
//  TrackPaddedSlider.swift
//  koin
//
//  Created by 이은지 on 8/8/25.
//

import UIKit

final class TrackPaddedSlider: UISlider {

    public var horizontalPadding: CGFloat = 0

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.trackRect(forBounds: bounds)
        
        let newRect = CGRect(
            x: originalRect.origin.x + horizontalPadding,
            y: originalRect.origin.y,
            width: originalRect.size.width - (horizontalPadding * 2),
            height: originalRect.size.height
        )
        
        return newRect
    }
}
