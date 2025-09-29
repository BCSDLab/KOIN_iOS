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
        super.init(frame: .zero, style: .insetGrouped)
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
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }*/
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        <#code#>
    }*/
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
        headerView.backgroundColor = .red
        return headerView
        /*
        switch section {
        case 0:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: OrderCartShopTitleHeaderView.identifier) as? OrderCartShopTitleHeaderView else {
                print("OrderCartShopTitleHeaderView : nil")
                return nil
            }
            guard let shopThumbnailImageUrl = cart.shopThumbnailImageUrl, let shopName = cart.shopName else {
                return nil
            }
            headerView.configure(shopThumbnailImageUrl: shopThumbnailImageUrl, shopName: shopName)
            headerView.backgroundColor = .red
            return headerView
        case 2:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: OrderCartAmountHeaderView.identifier) as? OrderCartAmountHeaderView else {
                print("OrderCartAmountHeaderView nil")
                return nil
            }
            headerView.backgroundColor = .blue
            return headerView
        default: return nil
        }*/
    }
}
 
extension OrderCartTableView: UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        //return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        /*
        switch section {
        case 0: return cart.items.count
        case 1, 2: return 1
        default: return 0
        }*/
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
        /*
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCartListCell.identifier, for: indexPath) as? OrderCartListCell else {
                return UITableViewCell()
            }
            cell.configure(item: cart.items[indexPath.row])
            cell.backgroundColor = .gray
            return cell
        case 1:
            let cell = OrderCartAddMoreCell()
            cell.backgroundColor = .brown
            return cell
        case 2:
            let cell = OrderCartAmountCell()
            //cell.configure()
            cell.backgroundColor = .green
            return cell
        default: return UITableViewCell()
        }
    }*/
}
extension OrderCartTableView {
    
    private func commonInit() {
        register(OrderCartShopTitleHeaderView.self, forHeaderFooterViewReuseIdentifier: OrderCartShopTitleHeaderView.identifier)
        /*
        register(OrderCartAmountHeaderView.self, forHeaderFooterViewReuseIdentifier: OrderCartAmountHeaderView.identifier)
        
        register(OrderCartListCell.self, forCellReuseIdentifier: OrderCartListCell.identifier)
        register(OrderCartAddMoreCell.self, forCellReuseIdentifier: OrderCartAddMoreCell.identifier)
        register(OrderCartAmountCell.self, forCellReuseIdentifier: OrderCartAmountCell.identifier)
        */
        delegate = self
        dataSource = self
    }
}
