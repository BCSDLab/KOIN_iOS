//
//  PassThroughView.swift
//  koin
//
//  Created by 홍기정 on 10/28/26.
//

import UIKit

final class PassThroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView === self ? nil : hitView
    }
}
