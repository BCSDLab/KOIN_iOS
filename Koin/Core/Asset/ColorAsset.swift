//
//  ColorAsset.swift
//  Koin
//
//  Created by 홍기정 on 5/31/26.
//

import Foundation

public enum ColorAsset {
    case primary100, primary200, primary300, primary400, primary500, primary600, primary700, primary800, primary900
    case sub100, sub200, sub300, sub400, sub500, sub600, sub700, sub800, sub900
    case neutral0, neutral50, neutral100, neutral200, neutral300, neutral400, neutral500, neutral600, neutral700, neutral800
    case danger50, danger100, danger200, danger300, danger400, danger500, danger600, danger700
    case warning50, warning100, warning200, warning300, warning400, warning500, warning600, warning700
    case success50, success100, success200, success300, success400, success500, success600, success700
    case info50, info100, info200, info300, info400, info500, info600, info700
    case bus1, bus2, bus3
    case yellow
    case gray
    case newBackground, new100, new300, new400, new500, new600, new700, new800, new900

    var hex: String {
        switch self {
        case .primary100: return "CFF1F9"
        case .primary200: return "A2DFF3"
        case .primary300: return "6DBBDD"
        case .primary400: return "4590BB"
        case .primary500: return "175C8E"
        case .primary600: return "10477A"
        case .primary700: return "0B3566"
        case .primary800: return "072552"
        case .primary900: return "041A44"

        case .sub100: return "FEF2D1"
        case .sub200: return "FEE1A4"
        case .sub300: return "FCCC77"
        case .sub400: return "FAB655"
        case .sub500: return "F7941E"
        case .sub600: return "D47415"
        case .sub700: return "B1580F"
        case .sub800: return "8F3F09"
        case .sub900: return "762E05"

        case .neutral0: return "FFFFFF"
        case .neutral50: return "FAFAFA"
        case .neutral100: return "F5F5F5"
        case .neutral200: return "EEEEEE"
        case .neutral300: return "E1E1E1"
        case .neutral400: return "CACACA"
        case .neutral500: return "727272"
        case .neutral600: return "4B4B4B"
        case .neutral700: return "1F1F1F"
        case .neutral800: return "000000"

        case .danger50: return "FFFBFB"
        case .danger100: return "FEF2F2"
        case .danger200: return "FFEBEE"
        case .danger300: return "FFCCD2"
        case .danger400: return "F49898"
        case .danger500: return "EB6F70"
        case .danger600: return "F64C4C"
        case .danger700: return "EC2D30"

        case .warning50: return "FFFDFA"
        case .warning100: return "FFF9EE"
        case .warning200: return "FFF7E1"
        case .warning300: return "FFEAB3"
        case .warning400: return "FFDD82"
        case .warning500: return "FFC62B"
        case .warning600: return "FFAD0D"
        case .warning700: return "FE9B0E"

        case .success50: return "FBFEFC"
        case .success100: return "F2FAF6"
        case .success200: return "E5F5EC"
        case .success300: return "C0E5D1"
        case .success400: return "97D4B4"
        case .success500: return "6BC497"
        case .success600: return "47B881"
        case .success700: return "0C9D61"

        case .info50: return "F8FCFF"
        case .info100: return "F1F8FF"
        case .info200: return "E4F2FF"
        case .info300: return "BDDDFF"
        case .info400: return "93C8FF"
        case .info500: return "4BA1FF"
        case .info600: return "3B82F6"
        case .info700: return "3A70E2"

        case .bus1: return "F7941E"
        case .bus2: return "7C9FAE"
        case .bus3: return "4DB297"
        case .yellow: return "#F4CE83"
        case .gray: return "8E8E8E"

        case .newBackground: return "F8F8FA"
        case .new100: return "EAD3FE"
        case .new300: return "CE86FD"
        case .new400: return "C358FC"
        case .new500: return "B611F5"
        case .new600: return "980AC9"
        case .new700: return "7D08A4"
        case .new800: return "600481"
        case .new900: return "401048"
        }
    }
}
