//
//  OrderCartListCellPriceTableView.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//

import UIKit

final class OrderCartListCellPriceTableView: UITableView {
    
    // MARK: - Properties
    private var options: [Option] = []
    
    // MARK: - Initializer
    
    func configure(price: CartPrice, options: [Option]) {
        var newOptions: [Option] = []
        let formatter = NumberFormatter().then { $0.numberStyle = .decimal }
        newOptions.append(Option(optionGroupName: price.name ?? "",
                              optionName: "\(formatter.string(from: NSNumber(value: price.price)) ?? "-")원",
                              optionPrice: nil))
        options.forEach {
            newOptions.append($0)
        }
        self.options = newOptions
        reloadData()
    }
}

extension OrderCartListCellPriceTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 21
    }
    //tableView
}

/*
 Cart(shopName: "굿모닝살로만치킨",
      shopThumbnailImageUrl: "https://static.koreatech.in/upload/owners/2024/03/28/ebef80af-9d18-44c8-b4dd-44c64f21a520-1711617869236/1693645787165.jpg",
      orderableShopId: 2,
      isDeliveryAvailable: true,
      isTakeoutAvailable: false,
      shopMinimumOrderAmount: 14000,
      items: [CartItem(
         cartMenuItemId: 906,
         orderableShopMenuId: 11,
         name: "후라이드 치킨",
         menuThumbnailImageUrl: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
         quantity: 2,
         totalAmount: 38000,
         price: CartPrice(
             name: nil,
             price: 19000),
         options: [],
         isModified: false)],
      itemsAmount: 62500,
      deliveryFee: 1500,
      totalAmount: 64000,
      finalPaymentAmount: 64000)
 */
