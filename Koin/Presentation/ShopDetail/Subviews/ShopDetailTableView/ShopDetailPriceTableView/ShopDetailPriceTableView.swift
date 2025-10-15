//
//  ShopDetailPriceTableView.swift
//  koin
//
//  Created by 홍기정 on 9/23/25.
//

import UIKit

final class ShopDetailPriceTableView: UITableView {
    
    // MARK: - Properties
    var prices: [Price] = []
    
    // MARK: - Initializer
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(prices: [Price]) {
        self.prices = prices
        reloadData()
    }
}

extension ShopDetailPriceTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .zero
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .zero
    }
}

extension ShopDetailPriceTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopDetailPriceTableViewCell.identifier, for: indexPath) as? ShopDetailPriceTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(price: prices[indexPath.row])
        return cell
    }
}

extension ShopDetailPriceTableView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        register(ShopDetailPriceTableViewCell.self, forCellReuseIdentifier: ShopDetailPriceTableViewCell.identifier)
    }
}
