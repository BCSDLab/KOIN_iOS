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
    private var cart: Cart = Cart.empty()
    let moveToShopPublisher = PassthroughSubject<Void, Never>()
    let addQuantityPublisher = PassthroughSubject<Int, Never>()
    let minusQuantityPublisher = PassthroughSubject<Int, Never>()
    let deleteItemPublisher = PassthroughSubject<Int, Never>()
    let changeOptionPublisher = PassthroughSubject<Int, Never>()
    let emptyCartPublisher = PassthroughSubject<Void, Never>()
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
        case 0: return 160
        case 1: return 58
        case 2: return 139
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 78
        case 2: return 62
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
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
        case 2:
            let headerView = OrderCartAmountHeaderView()
            return headerView
        default:
            return nil
        }
    }
}
 
extension OrderCartTableView: UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return cart.items.count
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCartListCell.identifier, for: indexPath) as? OrderCartListCell else {
                return UITableViewCell()
            }
            let isFirstRow: Bool = indexPath.row == 0
            let isLastRow: Bool = cart.items.count - 1 == indexPath.row
            cell.configure(item: cart.items[indexPath.row], isFirstRow: isFirstRow, isLastRow: isLastRow, indexPath: indexPath)
            
            cell.addQuantityPublisher
                .sink { [weak self] cartMenuItemId in
                    self?.addQuantityPublisher.send(cartMenuItemId)
                }
                .store(in: &subscriptions)
            cell.minusQuantityPublisher
                .sink { [weak self] cartMenuItemId in
                    self?.minusQuantityPublisher.send(cartMenuItemId)
                }
                .store(in: &subscriptions)
            cell.deleteItemPublisher
                .sink { [weak self] cartMenuItemId, indexPath in
                    self?.deleteItemPublisher.send(cartMenuItemId)
                    self?.removeItem(cartMenuItemId: cartMenuItemId)
                }
                .store(in: &subscriptions)
            cell.changeOptionPublisher
                .sink { [weak self] cartMenuItemId in
                    self?.changeOptionPublisher.send(cartMenuItemId)
                }
                .store(in: &subscriptions)
            return cell
        case 1:
            let cell = OrderCartAddMoreCell()
            cell.moveToShopPublisher
                .sink { [weak self] in
                    self?.moveToShopPublisher.send()
                }
                .store(in: &subscriptions)
            return cell
        case 2:
            let cell = OrderCartAmountCell()
            cell.configure(itemsAmount: cart.itemsAmount, deliveryFee: cart.deliveryFee, totalAmount: cart.totalAmount, finalPaymentAmount: cart.finalPaymentAmount)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension OrderCartTableView {
    
    func removeItem(cartMenuItemId: Int) {
        /// menuId에 해당하는 indexPath를 찾습니다.
        var indexPath: IndexPath? = nil
        for row in 0..<numberOfRows(inSection: 0) {
            if (cellForRow(at: IndexPath(row: row, section: 0)) as? OrderCartListCell)?.cartMenuItemId == cartMenuItemId {
                indexPath = IndexPath(row: row, section: 0)
                break
            }
        }
        guard let indexPath = indexPath else {
            return
        }
        /// 해당 row의 위치, 인접 row의 위치를 파악합니다.
        let isFirstRow: Bool = indexPath.row == 0
        let isNextLastRow: Bool = cart.items.count - 1 == indexPath.row + 1
        let isLastRow: Bool = cart.items.count - 1 == indexPath.row
        let isPreviousFirstRow: Bool = indexPath.row - 1 == 0
        /// 해당 row가 삭제되었을 때, 인접 row가 첫번째 또는 마지막, 또는 첫번째이자 마지막 cell이 된다면, radius와 separaterView를 적절하게 설정합니다.
        switch (isFirstRow, isLastRow) {
        case (true, true): break
        case (true, false):
            guard let nextCell = cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section)) as? OrderCartListCell else {
                return
            }
            nextCell.setUpInsetBackgroundView(isFirstRow: true, isLastRow: isNextLastRow)
        case (false, true):
            guard let previousCell = cellForRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section)) as? OrderCartListCell else {
                return
            }
            previousCell.setUpInsetBackgroundView(isFirstRow: true, isLastRow: isPreviousFirstRow)
        default: break
        }
        /// tabelView에서 해당 row를 삭제합니다.
        cart.items.remove(at: indexPath.row)
        deleteRows(at: [indexPath], with: .fade)
        
        /// cart가 비었다면, viewController에 publisher를 발행하여 tableView를 숨길 수 있도록합니다.
        if cart.items.isEmpty {
            emptyCartPublisher.send()
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
