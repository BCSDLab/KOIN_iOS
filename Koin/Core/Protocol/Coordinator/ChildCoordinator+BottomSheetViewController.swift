//
//  ChildCoordinator+BottomSheetViewController.swift
//  koin
//
//  Created by 홍기정 on 2026-05-29.
//

import UIKit

extension ChildCoordinator {
    func presentBottomSheetViewController(
        contentViewController route: Route,
        defaultHeight: CGFloat,
        cornerRadius: CGFloat = 16,
        dimmedAlpha: CGFloat = 0.4,
        isPannedable: Bool = false
    ) {
        let contentViewController = makeViewController(route: route)
        let bottomSheetViewController = BottomSheetViewController(
            contentViewController: contentViewController,
            defaultHeight: defaultHeight,
            cornerRadius: cornerRadius,
            dimmedAlpha: dimmedAlpha,
            isPannedable: isPannedable
        )
        bottomSheetViewController.modalTransitionStyle = .crossDissolve
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        
        navigationController.present(bottomSheetViewController, animated: false)
    }
    
    func presentBottomSheetViewControllerB(
        contentView: UIView,
        dimColor: UIColor = .black,
        dimAlpha: CGFloat = 0.4,
        backgroundColor: UIColor
    ) {
        let bottomSheetViewControllerB = BottomSheetViewControllerB(
            contentView: contentView,
            dimColor: dimColor,
            dimAlpha: dimAlpha,
            backgroundColor: backgroundColor
        )
        
        navigationController.present(bottomSheetViewControllerB, animated: false)
    }
}
