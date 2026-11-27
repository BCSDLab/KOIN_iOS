//
//  LandDetail.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import Foundation

struct LandDetail {
    let id: Int
    let name: String
    let coordinate: LandCoordinate?
    let imageUrls: [String]
    let monthlyFee: String?
    let charterFee: String?
    let deposit: String?
    let managementFee: String?
    let size: String?
    let roomType: String?
    let phone: String?
}

extension LandDetail {
    private static let inquiryText = "별도 문의"
    
    var rentText: String {
        Self.pairText(monthlyFee, charterFee)
    }
    
    var depositText: String {
        Self.pairText(deposit, managementFee)
    }
    
    var sizeText: String {
        size.map { "\($0)평" } ?? Self.inquiryText
    }
    
    var roomTypeText: String {
        roomType ?? Self.inquiryText
    }
    
    var phoneText: String {
        phone ?? Self.inquiryText
    }
    
    private static func pairText(_ first: String?, _ second: String?) -> String {
        if first == nil && second == nil {
            return inquiryText
        }
        return "\(first ?? inquiryText) / \(second ?? inquiryText)"
    }
}

