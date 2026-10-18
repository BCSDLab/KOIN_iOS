//
//  DiningReportAbTest.swift
//  koin
//
//  Created by 홍기정 on 10/16/26.
//

import Foundation

enum DiningReportAbTest {
    case nav
    case card
    
    var imageAsset: ImageAsset {
        switch self {
        case .nav:
            return .diningReportTooltipNav
        case .card:
            return .diningReportTooltipCard
        }
    }
}

extension DiningReportAbTest {
    init?(from variableName: String) {
        switch variableName {
        case "soldout_design_A":
            self = .nav
        case "soldout_design_B":
            self = .card
        default:
            return nil
        }
    }
}

