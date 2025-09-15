//
//  FetchCartAddRequest.swift
//  koin
//
//  Created by 홍기정 on 9/15/25.
//

import Foundation

struct FetchCartAddRequest: Encodable {
    let orderableShopID: Int
    let orderableShopMenuID: Int
    let orderableShopMenuPriceID: Int
    let orderableShopMenuOptionIDS: [OrderableShopMenuOptionID]
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case orderableShopID = "orderable_shop_id"
        case orderableShopMenuID = "orderable_shop_menu_id"
        case orderableShopMenuPriceID = "orderable_shop_menu_price_id"
        case orderableShopMenuOptionIDS = "orderable_shop_menu_option_ids"
        case quantity
    }
}

struct OrderableShopMenuOptionID: Encodable {
    let optionGroupID: Int
    let optionID: Int

    enum CodingKeys: String, CodingKey {
        case optionGroupID = "option_group_id"
        case optionID = "option_id"
    }
}
