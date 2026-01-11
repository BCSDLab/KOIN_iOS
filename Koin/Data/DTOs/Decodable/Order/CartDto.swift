//
//  CartDto.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Foundation

struct CartDto: Decodable {
    let shopName: String?
    let shopThumbnailImageUrl: String?
    let orderableShopId: Int?
    let isDeliveryAvailable, isTakeoutAvailable: Bool
    let shopMinimumOrderAmount: Int
    let items: [CartItemDto]
    let itemsAmount, deliveryFee, totalAmount, finalPaymentAmount: Int

    enum CodingKeys: String, CodingKey {
        case shopName = "shop_name"
        case shopThumbnailImageUrl = "shop_thumbnail_image_url"
        case orderableShopId = "orderable_shop_id"
        case isDeliveryAvailable = "is_delivery_available"
        case isTakeoutAvailable = "is_takeout_available"
        case shopMinimumOrderAmount = "shop_minimum_order_amount"
        case items
        case itemsAmount = "items_amount"
        case deliveryFee = "delivery_fee"
        case totalAmount = "total_amount"
        case finalPaymentAmount = "final_payment_amount"
    }
}

struct CartItemDto: Decodable {
    let cartMenuItemId, orderableShopMenuId: Int
    let name: String
    let menuThumbnailImageUrl: String?
    let quantity, totalAmount: Int
    let price: CartPriceDto
    let options: [OptionDto]
    let isModified: Bool

    enum CodingKeys: String, CodingKey {
        case cartMenuItemId = "cart_menu_item_id"
        case orderableShopMenuId = "orderable_shop_menu_id"
        case name
        case menuThumbnailImageUrl = "menu_thumbnail_image_url"
        case quantity
        case totalAmount = "total_amount"
        case price, options
        case isModified = "is_modified"
    }
}

struct OptionDto: Decodable {
    let optionGroupName, optionName: String
    let optionPrice: Int

    enum CodingKeys: String, CodingKey {
        case optionGroupName = "option_group_name"
        case optionName = "option_name"
        case optionPrice = "option_price"
    }
}

struct CartPriceDto: Decodable {
    let name: String?
    let price: Int
}
