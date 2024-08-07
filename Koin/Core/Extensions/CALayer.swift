//
//  CALayer.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/01.
//

import QuartzCore
import UIKit

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
//            print("check",frame.width)
            let border = CALayer()
            switch edge {
                
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 20, y: 0, width: UIScreen.main.bounds.width - 40, height: width)
                break
            case UIRectEdge.bottom:
                print(self.frame.height)
                border.frame = CGRect.init(x: 20, y: self.frame.height - 5, width: UIScreen.main.bounds.width - 40, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: self.frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: self.frame.width - width, y: 0, width: width, height: self.frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}
