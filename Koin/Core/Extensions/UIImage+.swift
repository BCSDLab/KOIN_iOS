//
//  UIImage+.swift
//  Koin
//
//  Created by 김나훈 on 1/15/24.
//

import UIKit.UIImage

enum ImageAsset: String {
    case logo
    case bus
    case line3
    case exchange
    case arrow
    case event
    case search
    case warning
    case possible1
    case possible2
    case arrowLeft
    case arrowRight
    case nonImage
    case option1
    case option2
    case option3
    case option4
    case option5
    case option6
    case option7
    case option8
    case option9
    case option10
    case option11
    case option12
    case option13
    case option14
    case option15
    case option16
    case mainLogo
    case koinLogo
    case write
    case nonMenuImage
    case noMeal
    case cancel
    case lamp
    case defaultMenuImage
    case noticeWarning
    case ownerReadyImage
    case recommandMenu
    case titleMenu
    case setMenu
    case sideMenu
    case arrowUp
    case arrowDown
    case ownerReadyEvent
    case call
    case star
    case emptyStar
    case coopInfo
    case arrowBack
    case heart
    case heartFill
    case share
    case diningTooltip
    case myReview
    case option
    case optionFill
    case circle
    case filledCircle
    case cancelYellow
    case trashcan
    case nonReview
    case reportedImageView
    case nonMenuWeekendImage
    case filter
    case eye
    case fireImage
    case delete
    case plus
    case download
    case noticeLoginToolTip
    case noticeNotLoginToolTip
    case popularStar
}

enum SFSymbols: String {
    case line3horizontal = "line.3.horizontal"
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case person = "person"
    case square
    case checkmarkSquare = "checkmark.square"
    case chevronDown = "chevron.down"
    case chevronUp = "chevron.up"
    case phone
    case magnifyingGlass = "magnifyingglass"
}

extension UIImage {
    
    static func appImage(asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
    
    static func appImage(symbol: SFSymbols) -> UIImage? {
        return UIImage(systemName: symbol.rawValue)
    }
    
}
