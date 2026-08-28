//
//  TimetableColorAsset.swift
//  Koin
//
//  Created by 홍기정 on 5/31/26.
//

import Foundation

public enum TimetableColorAsset {
    case header1, header2, header3, header4, header5, header6, header7, header8, header9, header10, header11, header12, header13, header14, header15
    case body1, body2, body3, body4, body5, body6, body7, body8, body9, body10, body11, body12, body13, body14, body15

    var hex: String {
        switch self {
        case .header1: return "890000"
        case .header2: return "FF4444"
        case .header3: return "FF993B"
        case .header4: return "E8D52A"
        case .header5: return "D0AE00"
        case .header6: return "513A00"
        case .header7: return "0C9D61"
        case .header8: return "7ABA78"
        case .header9: return "366718"
        case .header10: return "80C4E9"
        case .header11: return "1679AB"
        case .header12: return "074173"
        case .header13: return "523AE2"
        case .header14: return "6F6F6F"
        case .header15: return "CBCBCB"

        case .body1: return "E7CCCC"
        case .body2: return "FFDADA"
        case .body3: return "FFEBD8"
        case .body4: return "FAF7D4"
        case .body5: return "F6EFCC"
        case .body6: return "DCD8CC"
        case .body7: return "CEEBDF"
        case .body8: return "E4F1E4"
        case .body9: return "D7E1D1"
        case .body10: return "E6F3FB"
        case .body11: return "D0E4EE"
        case .body12: return "CDD9E3"
        case .body13: return "DCD8F9"
        case .body14: return "E2E2E2"
        case .body15: return "F5F5F5"
        }
    }
}
