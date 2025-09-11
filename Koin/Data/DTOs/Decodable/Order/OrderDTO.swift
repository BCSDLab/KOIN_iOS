//
//  OrderHistoryResponseDTO.swift
//  koin
//
//  Created by 김성민 on 9/10/25.
//

import Foundation

struct OrdersResponseDTO: Decodable {
    let totalCount: Int
    let currentCount: Int
    let totalPage: Int
    let currentPage: Int
    let orders: [OrderDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
        case orders
    }
}

struct OrderDTO: Decodable {
    let id: Int
    let paymentId: Int
    let orderableShopId: Int
    let orderableShopName: String
    let openStatus: OpenStatusAdapter
    let orderableShopThumbnail: String
    let orderDate: String
    let orderStatus: String
    let orderTitle: String
    let totalAmount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case paymentId = "payment_id"
        case orderableShopId = "orderable_shop_id"
        case orderableShopName = "orderable_shop_name"
        case openStatus = "open_status"
        case orderableShopThumbnail = "orderable_shop_thumbnail"
        case orderDate = "order_date"
        case orderStatus = "order_status"
        case orderTitle = "order_title"
        case totalAmount = "total_amount"
    }
}

extension OrderDTO {
    func toEntity() -> Order {
        let date = orderDate.toDateFromYYYYMMDD() ?? .distantPast
        let thumbURL = URL(string: orderableShopThumbnail)

        return Order(
            id: id,
            paymentId: paymentId,
            shopId: orderableShopId,
            shopName: orderableShopName,
            shopThumbnail: thumbURL,
            openStatus: openStatus.domain,
            orderDate: date,
            status: OrderStatus(rawValue: orderStatus) ?? .unknown,
            orderTitle: orderTitle,
            totalAmount: totalAmount
        )
    }
}

struct OpenStatusAdapter: Decodable {
    let domain: OpenStatus

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if c.decodeNil() {
            domain = .unknown
            return
        }
        if let b = try? c.decode(Bool.self) {
            domain = b ? .operating : .closed
            return
        }
        if let s = try? c.decode(String.self) {
            let u = s.uppercased()
            if let mapped = OpenStatus(rawValue: u) {
                domain = mapped
            } else {
                switch u {
                case "OPEN": domain = .operating
                case "CLOSE": domain = .closed
                default: domain = .unknown
                }
            }
            return
        }
        domain = .unknown
    }
}

