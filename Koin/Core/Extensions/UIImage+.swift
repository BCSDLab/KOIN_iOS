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
    case chevronRight
    case chevronUp
    case visibility
    case visibilityNon
    case check
    case checkGreen
    case topCircle
    case gear
    case copy
    case filter
    case eye
    case fireImage
    case delete
    case plus
    case download
    case noticeLoginToolTip
    case noticeNotLoginToolTip
    case popularStar
    case shopButton
    case callBenefitButton
    case smallShop
    case smallBenefit
    case koinBigLogo
    case power
    case reviewTooltip
    case store
    case menu
    case arrowUpLeft
    case noticeBell
    case downloadBold
    case plusCircle
    case classFilter
    case add
    case minusCircle
    case bookmark
    case plusBold
    case checkFill
    case checkEmpty
    case callBlue
    case qrCode
    case incorrectInfo
    case swap
    case busStop
    case findPerson
    case addCircle
    case picture
    case trashcanBlue
    case warningOrange
    case cancelBlue
    case trashcanSmall
    case pencil
    case chevronDown
    case chat
    case siren
    case lostItem
    case blind
    case basicPicture
    case threeCircle
    case block
    case gallery
    case send
    case checkEmptyCircle
    case checkFilledCircle
    case cancelNeutral500
    case circlePrimary500
    case circleCheckedPrimary500
    case checkGreenCircle
    case warningRed
    case findId
    case findPassword
    case chevronRightBlue
    case note
    case club1
    case club2
    case club3
    case club4
    case club5
    case toastMessageIconInformative
    case toastMessageIconPositive
    case toastMessageIconNegative
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
    
    func resize(to size: CGSize) -> UIImage? {
        return UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
