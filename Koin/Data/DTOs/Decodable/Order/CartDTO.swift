//
//  CartDTO.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Foundation

struct CartDTO: Decodable {
    let shopName: String?
    let shopThumbnailImageURL: String?
    let orderableShopID: Int?
    let isDeliveryAvailable, isTakeoutAvailable: Bool
    let shopMinimumOrderAmount: Int
    let items: [CartItemDTO]
    let itemsAmount, deliveryFee, totalAmount, finalPaymentAmount: Int

    enum CodingKeys: String, CodingKey {
        case shopName = "shop_name"
        case shopThumbnailImageURL = "shop_thumbnail_image_url"
        case orderableShopID = "orderable_shop_id"
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

struct CartItemDTO: Decodable {
    let cartMenuItemID, orderableShopMenuID: Int
    let name: String
    let menuThumbnailImageURL: String
    let quantity, totalAmount: Int
    let price: CartPriceDTO
    let options: [OptionDTO]
    let isModified: Bool

    enum CodingKeys: String, CodingKey {
        case cartMenuItemID = "cart_menu_item_id"
        case orderableShopMenuID = "orderable_shop_menu_id"
        case name
        case menuThumbnailImageURL = "menu_thumbnail_image_url"
        case quantity
        case totalAmount = "total_amount"
        case price, options
        case isModified = "is_modified"
    }
}

struct OptionDTO: Decodable {
    let optionGroupName, optionName: String
    let optionPrice: Int

    enum CodingKeys: String, CodingKey {
        case optionGroupName = "option_group_name"
        case optionName = "option_name"
        case optionPrice = "option_price"
    }
}

struct CartPriceDTO: Decodable {
    let name: String?
    let price: Int
}
