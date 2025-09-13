//
//  OrderHistoryResponseDTO.swift
//  koin
//
//  Created by 김성민 on 9/10/25.
//

import Foundation

struct OrdersHistoryResponseDTO: Decodable {
    let totalCount: Int
    let currentCount: Int
    let totalPage: Int
    let currentPage: Int
    let orders: [OrderHistoryDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
        case orders
    }
}

extension OrdersHistoryResponseDTO {
    func toPageEntity() -> OrdersPage {
        OrdersPage(
            totalCount: totalCount,
            currentCount: currentCount,
            totalPage: totalPage,
            currentPage: currentPage,
            orders: orders.map { $0.toEntity() }
        )
    }
}

struct OrderHistoryDTO: Decodable {
    let id: Int
    let paymentId: Int
    let orderableShopId: Int
    let orderableShopName: String
    let openStatus: Bool
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

extension OrderHistoryDTO {
    func toEntity() -> OrderHistory {
        let date = orderDate.toDateFromYYYYMMDD() ?? .distantPast
        let thumbURL = URL(string: orderableShopThumbnail)

        return OrderHistory(
            id: id,
            paymentId: paymentId,
            shopId: orderableShopId,
            shopName: orderableShopName,
            shopThumbnail: thumbURL,
            openStatus: openStatus,
            orderDate: date,
            status: OrderStatus(rawValue: orderStatus) ?? .unknown,
            orderTitle: orderTitle,
            totalAmount: totalAmount
        )
    }
}

