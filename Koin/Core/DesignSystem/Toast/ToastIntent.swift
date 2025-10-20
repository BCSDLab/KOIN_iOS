//
//  ToastIntent.swift
//  koin
//
//  Created by 이은지 on 10/19/25.
//

import UIKit

enum ToastIntent {
    case neutral
    case informative
    case positive
    case negative

    var toastMessageIcon: UIImage? {
        switch self {
        case .neutral:
            return nil
        case .informative:
            return UIImage.appImage(asset: .toastMessageIconInformative)
        case .positive:
            return UIImage.appImage(asset: .toastMessageIconPositive)
        case .negative:
            return UIImage.appImage(asset: .toastMessageIconNegative)
        }
    }
}
