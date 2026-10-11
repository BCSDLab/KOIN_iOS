//
//  ExtendedTouchAreaView.swift
//  koin
//
//  Created by 홍기정 on 1/23/26.
//

import UIKit

/// SuperView(ExtendedTouchAreaView)의 바깥 영역에 위치한 Subview의 터치 이벤트가 작동하도록 합니다.
class ExtendedTouchAreaView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) {
            return true
        }
        
        for subview in subviews {
            let pointInSubview = subview.convert(point, from: self)
            if !subview.isHidden
                && subview.isUserInteractionEnabled
                && subview.point(inside: pointInSubview, with: event) {
                return true
            }
        }
        return false
    }
}
