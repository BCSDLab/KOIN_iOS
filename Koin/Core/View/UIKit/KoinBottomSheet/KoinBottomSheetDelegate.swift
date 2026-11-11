//
//  KoinBottomSheetDelegate.swift
//  koin
//
//  Created by 홍기정 on 10/28/26.
//

import UIKit

@MainActor
protocol KoinBottomSheetDelegate: AnyObject {
    func dismiss(completion: (() -> Void)?)
    func invalidateHeight(animated: Bool)
    func setFullScreen(_ fullScreen: Bool, animated: Bool)
}

extension KoinBottomSheetDelegate {
    func dismiss() {
        dismiss(completion: nil)
    }
}
