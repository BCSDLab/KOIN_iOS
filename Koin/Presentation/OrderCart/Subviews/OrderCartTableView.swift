//
//  OrderCartTableView.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//

import UIKit
import Combine

final class OrderCartTableView: UITableView {
    
    // MARK: - Properties
    private var cart = Cart.empty()
    let moveToShopPublisher = PassthroughSubject<Void, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
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
        reloadData()
    }
}

extension OrderCartTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 68
        case 1: return 160
        case 2: return 58
        case 3: return 139
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1: return 78
        case 3: return 62
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let headerView = OrderCartShopTitleHeaderView()
            guard let shopName = cart.shopName else {
                return nil
            }
            headerView.configure(shopThumbnailImageUrl: cart.shopThumbnailImageUrl, shopName: shopName)
            headerView.moveToShopPublisher
                .sink { [weak self] in
                    self?.moveToShopPublisher.send()
                }
                .store(in: &subscriptions)
            return headerView
        case 3:
            let headerView = OrderCartAmountHeaderView()
            return headerView
        default:
            return nil
        }
    }
}
 
extension OrderCartTableView: UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: return cart.items.count
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = OrderCartSegmentedControlCell()
            cell.configure(isDeliveryAvailable: cart.isDeliveryAvailable, isPickupAvailable: cart.isTakeoutAvailable)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCartListCell.identifier, for: indexPath) as? OrderCartListCell else {
                return UITableViewCell()
            }
            let isFirstRow: Bool = indexPath.row == 0
            let isLastRow: Bool = cart.items.count - 1 == indexPath.row
            cell.configure(item: cart.items[indexPath.row], isFirstRow: isFirstRow, isLastRow: isLastRow)
            return cell
        case 2:
            let cell = OrderCartAddMoreCell()
            cell.moveToShopPublisher
                .sink { [weak self] in
                    self?.moveToShopPublisher.send()
                }
                .store(in: &subscriptions)
            return cell
        case 3:
            let cell = OrderCartAmountCell()
            cell.configure(itemsAmount: cart.itemsAmount, deliveryFee: cart.deliveryFee, totalAmount: cart.totalAmount, finalPaymentAmount: cart.finalPaymentAmount)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
extension OrderCartTableView {
    
    private func commonInit() {
        register(OrderCartListCell.self, forCellReuseIdentifier: OrderCartListCell.identifier)
        delegate = self
        dataSource = self
    }
}
