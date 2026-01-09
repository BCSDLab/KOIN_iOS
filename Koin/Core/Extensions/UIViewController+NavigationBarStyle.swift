//
//  UIViewController+NavigationBarStyle.swift
//  koin
//
//  Created by 김나훈 on 12/3/24.
//

import UIKit

extension UIViewController {
    
    enum NavigationBarStyle {
        case fill
        case empty
        case order
        case orderTransparent
        case transparentBlack
        case transparentWhite
        
        var backgroundColor: UIColor {
            switch self {
            case .fill:
                return UIColor.appColor(.primary500)
            case .empty:
                return UIColor.appColor(.neutral0)
            case .order:
                return UIColor.appColor(.newBackground)
            case .orderTransparent, .transparentBlack, .transparentWhite:
                return UIColor.clear
            }
        }
        
        var foregroundColor: UIColor {
            switch self {
            case .fill, .transparentWhite:
                return UIColor.appColor(.neutral0)
            case .empty, .order, .transparentBlack:
                return UIColor.appColor(.neutral800)
            case .orderTransparent:
                return UIColor.clear
            }
        }
        
        var font: UIFont {
            return UIFont.appFont(.pretendardMedium, size: 18)
        }
        
        var tintColor: UIColor {
            switch self {
            case .fill, .orderTransparent, .transparentWhite:
                return UIColor.appColor(.neutral0)
            case .empty, .order, .transparentBlack:
                return UIColor.appColor(.neutral800)
            }
        }
    }
        
    func configureNavigationBar(style: NavigationBarStyle) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = style.backgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: style.foregroundColor,
            .font: style.font
        ]
        
        navigationItem.backButtonTitle = ""
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
        navigationController?.navigationBar.tintColor = style.tintColor
        
        
    }
}
