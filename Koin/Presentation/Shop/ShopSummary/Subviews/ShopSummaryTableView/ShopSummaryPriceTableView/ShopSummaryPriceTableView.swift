//
//  ShopSummaryPriceTableView.swift
//  koin
//
//  Created by 홍기정 on 9/23/25.
//

import UIKit

final class ShopSummaryPriceTableView: UITableView {
    
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

extension ShopSummaryPriceTableView: UITableViewDelegate {

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

extension ShopSummaryPriceTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopSummaryPriceTableViewCell.identifier, for: indexPath) as? ShopSummaryPriceTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(price: prices[indexPath.row])
        return cell
    }
}

extension ShopSummaryPriceTableView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        register(ShopSummaryPriceTableViewCell.self, forCellReuseIdentifier: ShopSummaryPriceTableViewCell.identifier)
    }
}
