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
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(price: CartPrice, options: [Option]) {
        var newOptions: [Option] = []
        let formatter = NumberFormatter().then { $0.numberStyle = .decimal }
        newOptions.append(Option(optionGroupName: "가격",
                              optionName: "\(formatter.string(from: NSNumber(value: price.price)) ?? "-")원",
                              optionPrice: 0))
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
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension OrderCartListCellPriceTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCartListCellPriceTableViewCell.identifier, for: indexPath) as? OrderCartListCellPriceTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(option: options[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
}

extension OrderCartListCellPriceTableView {
    
    private func commonInit() {
        register(OrderCartListCellPriceTableViewCell.self, forCellReuseIdentifier: OrderCartListCellPriceTableViewCell.identifier)
        delegate = self
        dataSource = self
    }
}
