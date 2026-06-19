//
//  AppLaunchPresentation.swift
//  koin
//
//  Created by 홍기정 on 5/30/26.
//

import Foundation

enum AppLaunchPresentation {
    case none
    case forceUpdate(requiredVersion: String)
    case forceModifyUser
}
