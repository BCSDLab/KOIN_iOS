//
//  UIImage+.swift
//  Koin
//
//  Created by 김나훈 on 1/15/24.
//

import UIKit.UIImage

enum ImageAsset: String {
    
    // MARK: - Bus
    case bus
    case busStop
    case swap
    
    // MARK: - Chat
    case basicPicture
    case block
    
    // MARK: - Club
    case club1
    case club2
    case club3
    case club4
    case club5
    
    // MARK: - Dining
    case coopInfo
    case diningShare
    case diningTooltip
    case nonMenuImage
    case nonMenuWeekendImage
    
    // MARK: - Icon
    case add
    case addCircle
    case addGray
    case addPhotoAlternate
    case addThin
    case arrowBack
    case arrowDown
    case arrowUpLeft
    case blind
    case bookmark
    case cancel
    case cancelBlue
    case cancelGray
    case cancelNeutral500
    case cancelNew300
    case cancelYellow
    case chat
    case check
    case checkEmpty
    case checkEmptyCircle
    case checkFill
    case checkFilledCircle
    case checkGreen
    case checkGreenCircle
    case chevronDown
    case chevronRight
    case chevronRightHome
    case chevronUp
    case circle
    case circleCheckedPrimary500
    case circlePrimary500
    case classFilter
    case copy
    case defaultMenuImage
    case delete
    case delivery2
    case download
    case downloadBold
    case emptyStar
    case event
    case exchange
    case eye
    case filledCircle
    case findId
    case findPassword
    case findPerson
    case fireImage
    case gallery
    case gear
    case heart
    case heartFill
    case incorrectInfo
    case lamp
    case line3
    case menu
    case minus
    case minusCircle
    case myReview
    case newChevronRight
    case noMeal
    case nonImage
    case note
    case noticeBell
    case noticeWarning
    case option
    case optionFill
    case packaging
    case pencil
    case picture
    case plus
    case plusBold
    case plusCircle
    case popularStar
    case possible1
    case possible2
    case power
    case qrCode
    case recommandMenu
    case refresh
    case reportedImageView
    case search
    case send
    case setMenu
    case share
    case sideMenu
    case siren
    case smallBenefit
    case smallShop
    case speaker
    case star
    case store
    case successCircle
    case threeCircle
    case titleMenu
    case toastMessageIconInformative
    case toastMessageIconNegative
    case toastMessageIconPositive
    case topCircle
    case trashcan
    case trashcanBlue
    case trashcanNew
    case trashcanSmall
    case visibility
    case visibilityNon
    case warning
    case warningOrange
    case warningRed
    case write
    
    // MARK: - Land
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
    
    // MARK: - Logo
    case bcsdSymbolLogo
    case koinBigLogo
    case koinLogo
    case logo
    case mainLogo
    case newLogo
    case sleepBcsdSymbol
    
    // MARK: - LostItem
    case lostItem
    
    // MARK: - Notice
    case noticeLoginToolTip
    case noticeNotLoginToolTip
    
    // MARK: - Shop
    case call
    case callBenefit
    case callBenefitButton
    case callBlue
    case callNew
    case countIcon0
    case countIcon1
    case countIcon2
    case countIcon3
    case countIcon4
    case countIcon5
    case countIcon6
    case countIcon7
    case countIcon8
    case countIcon9
    case countIcon9Plus
    case filter
    case filterIcon1
    case filterIcon2
    case filterIcon3
    case filterIcon4
    case nonReview
    case orderDetailTabBar
    case orderEmptyLogo
    case orderHomeTabBar
    case orderShopTabBar
    case ownerReadyEvent
    case ownerReadyImage
    case reviewTooltip
    case shop
    case shopBenefit
    case shopButton
    case shoppingCart
    case shoppingCartLarge
    case shoppingCartShadowOval
    case shoppingCartShadowSquare
    case shoppingCartWhite
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
