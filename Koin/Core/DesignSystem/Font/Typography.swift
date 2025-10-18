//
//  Typography.swift
//  koin
//
//  Created by 이은지 on 10/18/25.
//

import UIKit

enum Typography {
    case display1
    case display2
    
    case title1
    case title2
    case title3
    case title3Strong
    
    case subtitle1
    
    case body1
    case body1Strong
    case body1Stronger
    case body2
    case body2Strong
    case body2Stronger
    
    case caption
    case captionStrong
    case captionStronger
    case caption2
    case caption2Strong
    
    // MARK: - Font Properties
    var font: UIFont {
        let fontName: String
        let size: CGFloat
        
        switch self {
        case .display1:
            fontName = FontFamily.pretendardBold
            size = 36
        case .display2:
            fontName = FontFamily.pretendardBold
            size = 32
            
        case .title1:
            fontName = FontFamily.pretendardBold
            size = 28
        case .title2:
            fontName = FontFamily.pretendardSemiBold
            size = 24
        case .title3:
            fontName = FontFamily.pretendardSemiBold
            size = 20
        case .title3Strong:
            fontName = FontFamily.pretendardBold
            size = 20
            
        case .subtitle1:
            fontName = FontFamily.pretendardSemiBold
            size = 18
            
        case .body1:
            fontName = FontFamily.pretendardRegular
            size = 17
        case .body1Strong:
            fontName = FontFamily.pretendardMedium
            size = 17
        case .body1Stronger:
            fontName = FontFamily.pretendardSemiBold
            size = 17
        case .body2:
            fontName = FontFamily.pretendardRegular
            size = 15
        case .body2Strong:
            fontName = FontFamily.pretendardMedium
            size = 15
        case .body2Stronger:
            fontName = FontFamily.pretendardSemiBold
            size = 15
            
        case .caption:
            fontName = FontFamily.pretendardRegular
            size = 13
        case .captionStrong:
            fontName = FontFamily.pretendardMedium
            size = 13
        case .captionStronger:
            fontName = FontFamily.pretendardSemiBold
            size = 13
        case .caption2:
            fontName = FontFamily.pretendardRegular
            size = 12
        case .caption2Strong:
            fontName = FontFamily.pretendardMedium
            size = 12
        }
        
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
    }
    
    // MARK: - Line Height
    var lineHeight: CGFloat {
        let size = font.pointSize
        let percentage: CGFloat
        
        switch self {
        case .display2, .title1:
            percentage = 1.5 // 150%
        default:
            percentage = 1.6 // 160%
        }
        
        return size * percentage
    }
    
    // MARK: - Line Spacing Calculation
    var lineSpacing: CGFloat {
        return lineHeight - font.lineHeight
    }
}

// MARK: - Font Family
private enum FontFamily {
    static let pretendardRegular = "Pretendard-Regular"
    static let pretendardMedium = "Pretendard-Medium"
    static let pretendardSemiBold = "Pretendard-SemiBold"
    static let pretendardBold = "Pretendard-Bold"
}

// MARK: - UIFont Extension
extension UIFont {
    /// Typography 스타일로 폰트 생성
    /// - Parameter typography: Typography 케이스
    /// - Returns: 해당 Typography의 UIFont
    static func setFont(_ typography: Typography) -> UIFont {
        return typography.font
    }
}
