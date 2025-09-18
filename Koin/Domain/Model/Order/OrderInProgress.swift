//
//  OrderInProgress.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import Foundation

struct OrderInProgress: Hashable {
    let id: Int
    let paymentId: Int
    let type: OrderInProgressType
    let orderableShopName: String
    let orderableShopThumbnail: String
    let estimatedTime: String
    let status: OrderInProgressStatus
    let orderTitle: String
    let totalAmount: Int
}

enum OrderInProgressType: String {
    case delivery = "DELIVERY"
    case takeout = "TAKEOUT"
}

enum OrderInProgressStatus: String {
    case confirming = "CONFIRMING"
    case cooking = "COOKING"
    case packaged = "PACKAGED"
    case pickedUp = "PICKED_UP"
    case delivering = "DELIVERING"
    case delivered = "DELIVERED"
    case canceled = "CANCELED"
    
    
}

extension OrderInProgress {
    var floatingTitleText: String {
        switch (type, status) {
        case (.delivery, .confirming):
            return "\(estimatedTime) 도착예정"
        case (.delivery, .cooking):
            return "주문 확인 중"
        case (.takeout, .cooking):
            return "\(estimatedTime) 포장 수령가능"
        default:
            return ""
        }
    }

    var floatingSubtitleText: String {
        return orderableShopName
    }
}

extension OrderInProgressStatus {
    var showEstimatedTime: Bool {
        switch self {
        case .cooking, .delivering:
            return true
        case .confirming, .pickedUp, .delivered, .canceled, .packaged:
            return false
        }
    }
}

extension OrderInProgress {
    var methodText: String {
        switch type {
        case .delivery: return "배달"
        case .takeout: return "포장"
        }
    }
    
    var stateText: String {
        switch type {
        case .delivery:
            switch status {
            case .confirming: return "주문 확인중"
            case .cooking: return "조리 중"
            case .delivering: return "배달 출발"
            case .delivered: return "배달 완료"
            case .canceled: return "주문 취소"
            case .packaged, .pickedUp: return ""
            }
        case .takeout:
            switch status {
            case .confirming: return "주문 확인중"
            case .cooking: return "조리 중"
            case .packaged, .pickedUp: return "수령 가능"
            case .canceled: return "주문 취소"
            case .delivered, .delivering: return ""
            }
        }
    }
    
    var explanationText: String {
        switch type {
        case .delivery:
            switch status {
            case .confirming:
                return "사장님이 주문을 확인하고 있어요"
            case .cooking, .packaged, .pickedUp:
                return "가게에서 열심히 음식을 조리하고 있어요!"
            
            case .delivering:
                return "열심히 달려가는 중이에요!"
            case .delivered:
                return "배달이 완료되었어요 감사합니다!"
            case .canceled:
                return ""
            }
        case .takeout:
            switch status {
            case .confirming:
                return "사장님이 주문을 확인하고 있어요"
            case .cooking, .delivering , .delivered:
                return "가게에서 열심히 음식을 조리하고 있어요!"
            case .packaged, .pickedUp:
                return "준비가 완료되었어요!"
            case .canceled:
                return ""
            }
        }
    }
    var estimatedTimeText: String {
        if estimatedTime == "시간 미정" { return "시간 미정" }
        switch type {
        case .delivery: return "\(estimatedTime) 도착 예정"
        case .takeout:  return "\(estimatedTime) 수령 가능"
        }
    }
}


