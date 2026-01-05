//
//  BottomSheetViewControllerPresentable.swift
//  koin
//
//  Created by 홍기정 on 1/5/26.
//

import UIKit

extension Coordinator {
    
    func presentBottomSheetViewController(
        contentViewController: UIViewController,
        defaultHeight: CGFloat,
        cornerRadius: CGFloat = 16,
        dimmedAlpha: CGFloat = 0.4,
        isPannedable: Bool = false,
        modalPresentationStyle: UIModalPresentationStyle = .overFullScreen,
        modalTransitionStyle: UIModalTransitionStyle = .coverVertical
    ) {
        let bottomSheetViewController = BottomSheetViewController(
            contentViewController: contentViewController,
            defaultHeight: defaultHeight,
            cornerRadius: cornerRadius,
            dimmedAlpha: dimmedAlpha,
            isPannedable: isPannedable
        )
        bottomSheetViewController.modalPresentationStyle = modalPresentationStyle
        bottomSheetViewController.modalTransitionStyle = modalTransitionStyle
        navigationController.present(bottomSheetViewController, animated: true)
    }
}
