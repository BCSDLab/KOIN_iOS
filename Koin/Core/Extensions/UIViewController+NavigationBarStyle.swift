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
        case white
    }
    
    func configureNavigationBar(style: NavigationBarStyle) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        switch style {
        case .fill:
            appearance.backgroundColor = UIColor.appColor(.primary500)
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.appColor(.neutral0),
                .font: UIFont.appFont(.pretendardMedium, size: 18)
            ]
            navigationItem.backButtonTitle = ""
        case .empty:
            appearance.backgroundColor = UIColor.appColor(.neutral0)
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.appColor(.neutral800),
                .font: UIFont.appFont(.pretendardMedium, size: 18)
            ]
            navigationItem.backButtonTitle = ""
        case .order:
            appearance.backgroundColor = UIColor.appColor(.newBackground)
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.appColor(.neutral800),
                .font: UIFont.appFont(.pretendardMedium, size: 18)
            ]
            navigationItem.backButtonTitle = ""
        case .orderTransparent:
            appearance.backgroundColor = UIColor.clear
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.clear,
                .font: UIFont.appFont(.pretendardSemiBold, size: 18)
            ]
            navigationItem.backButtonTitle = ""
        case .white:
            appearance.backgroundColor = UIColor.white
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.appColor(.neutral800),
                .font: UIFont.appFont(.pretendardMedium, size: 18)
            ]
            navigationItem.backButtonTitle = ""
        }
        appearance.shadowColor = nil
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        switch style {
        case .fill, .orderTransparent:
            navigationController?.navigationBar.tintColor = UIColor.appColor(.neutral0)
        case .empty, .order, .white:
            navigationController?.navigationBar.tintColor = UIColor.appColor(.neutral800)
        }
    }
}
