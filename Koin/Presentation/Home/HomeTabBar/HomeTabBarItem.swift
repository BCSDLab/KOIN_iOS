//
//  HomeTabBarItem.swift
//  koin
//
//  Created by 홍기정 on 6/24/26.
//

import UIKit

struct HomeTabBarItem {
    let viewController: UIViewController
    let tab: HomeTab
}

enum HomeTab: Int {
    case home
    case category
    case board
    case profile
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .category:
            return "카테고리"
        case .board:
            return "게시판"
        case .profile:
            return "프로필"
        }
    }
    
    var imageAsset: ImageAsset {
        switch self {
        case .home:
            return .tabbarHome
        case .category:
            return .tabbarCategory
        case .board:
            return .tabbarNotice
        case .profile:
            return .tabbarProfile
        }
    }

    var logLabel: EventParameter.EventLabel.Campus {
        switch self {
        case .home:
            return .navHome
        case .category:
            return .navCategory
        case .board:
            return .navBulletin
        case .profile:
            return .navProfile
        }
    }
}
