//
//  OrderCartTableView.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//

import UIKit

final class OrderCartTableView: UITableView {
    
    // MARK: - Properties
    private var cart = Cart.dummy()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .grouped)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(cart: Cart) {
        self.cart = cart
    }
}

extension OrderCartTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1: return 46
        default: return 160
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 78
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: OrderCartShopTitleHeaderView.identifier) as? OrderCartShopTitleHeaderView else {
            print("OrderCartShopTitleHeaderView : nil")
            return nil
        }
        guard let shopThumbnailImageUrl = cart.shopThumbnailImageUrl, let shopName = cart.shopName else {
            return nil
        }
        headerView.configure(shopThumbnailImageUrl: shopThumbnailImageUrl, shopName: shopName)
        return headerView
    }
}
 
extension OrderCartTableView: UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        //return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCartListCell.identifier, for: indexPath) as? OrderCartListCell else {
            return UITableViewCell()
        }
        let isFirstRow: Bool = indexPath.row == 0
        let isLastRow: Bool = cart.items.count - 1 == indexPath.row
        cell.configure(item: cart.items[indexPath.row], isFirstRow: isFirstRow, isLastRow: isLastRow)
        return cell
    }
}
extension OrderCartTableView {
    
    private func commonInit() {
        register(OrderCartShopTitleHeaderView.self, forHeaderFooterViewReuseIdentifier: OrderCartShopTitleHeaderView.identifier)
        register(OrderCartListCell.self, forCellReuseIdentifier: OrderCartListCell.identifier)
        delegate = self
        dataSource = self
    }
}
