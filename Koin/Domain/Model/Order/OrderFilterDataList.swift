//
//  OrderFilterData.swift
//  koin
//
//  Created by 이은지 on 6/22/25.
//

import UIKit

struct OrderFilterData {
    let type: FetchOrderShopFilterType    // 필터 타입
    let image: UIImage?                   // 필터 아이콘
    let label: String                     // 표시 텍스트
    var isSelected: Bool                  // 선택 상태
}

extension OrderFilterData {
    static func dummy() -> [OrderFilterData] {
        return [
            OrderFilterData(type: .isOpen, image: UIImage.appImage(asset: .filterIcon1), label: "영업중", isSelected: true),
            OrderFilterData(type: .deliveryAvailable, image: UIImage.appImage(asset: .filterIcon2), label: "배달가능", isSelected: false),
            OrderFilterData(type: .takeoutAvailable, image: UIImage.appImage(asset: .filterIcon3), label: "포장가능", isSelected: false),
            OrderFilterData(type: .freeDeliveryTip, image: UIImage.appImage(asset: .filterIcon4), label: "배달팁무료", isSelected: false),
        ]
    }
}
