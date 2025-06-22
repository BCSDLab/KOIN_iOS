//
//  OrderFilterData.swift
//  koin
//
//  Created by 이은지 on 6/22/25.
//

import UIKit

struct OrderFilterData {
    let image: UIImage?
    let label: String
}

extension OrderFilterData {
    static func dummy() -> [OrderFilterData] {
        return [
            OrderFilterData(image: UIImage.appImage(asset: .filterIcon1), label: "영업중"),
            OrderFilterData(image: UIImage.appImage(asset: .filterIcon2), label: "배달가능"),
            OrderFilterData(image: UIImage.appImage(asset: .filterIcon3), label: "포장가능"),
            OrderFilterData(image: UIImage.appImage(asset: .filterIcon4), label: "배달팁무료"),
        ]
    }
}
