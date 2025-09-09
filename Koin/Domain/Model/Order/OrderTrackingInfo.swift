//
//  OrderTrackingInfo.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import Foundation

// TODO: - API 나오면 수정
// 주문 상태를 표현하는 Enum
enum OrderStatus {
    case confirming
    case delivering(expectedAt: Date)
    case pickupReady(expectedAt: Date)
    case unknown
}

struct OrderTrackingInfo {
    let shopName: String
    let status: OrderStatus
    
    init?(from dto: OrderTrackingDTO) {
        self.shopName = dto.shopName
        
        let dateFormatter = ISO8601DateFormatter()
        
        switch dto.orderStatus {
        case "WAITING", "ACCEPTED":
            self.status = .confirming
            
        case "DELIVERING":
            guard let dateString = dto.expectedAt,
                  let date = dateFormatter.date(from: dateString) else { return nil }
            self.status = .delivering(expectedAt: date)
            
        case "PICKUP_READY":
            guard let dateString = dto.expectedAt,
                  let date = dateFormatter.date(from: dateString) else { return nil }
            self.status = .pickupReady(expectedAt: date)
            
        default:
            self.status = .unknown
        }
    }
    
    var titleText: String {
        switch status {
        case .confirming:
            return "주문 확인 중"
        case .delivering(let expectedAt):
            return "\(formatDate(expectedAt)) 도착예정"
        case .pickupReady(let expectedAt):
            return "\(formatDate(expectedAt)) 포장 수령가능"
        case .unknown:
            return "주문 정보 불러오는 중"
        }
    }
    
    var subtitleText: String {
        return shopName
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h시 mm분" // a: 오전/오후
        return formatter.string(from: date)
    }
}
