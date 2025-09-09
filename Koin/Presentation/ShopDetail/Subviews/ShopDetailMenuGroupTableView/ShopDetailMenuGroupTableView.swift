//
//  ShopDetailMenuGroupTableView.swift
//  koin
//
//  Created by 홍기정 on 9/8/25.
//

import UIKit
import Combine

class ShopDetailMenuGroupTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var menuGroupName: [String] = [""]
    var names: [[String]] = [[""]]
    var descriptions: [[String?]] = [[nil]]
    var prices: [[[Price]]] = [[[Price(id: 0, name: nil, price: 0)]]]
    var thumbnailImages: [[String?]] = [[nil]]
    
    // MARK: - Components
    
    // MARK: - Initializer
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setTableView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind(orderShopMenusGroups: [OrderShopMenusGroup]) {
        self.menuGroupName = []
        self.names = []
        self.descriptions = []
        self.prices = []
        self.thumbnailImages = []
        
        orderShopMenusGroups.forEach {
            self.menuGroupName.append($0.menuGroupName)
            
            var names: [String] = []
            var descriptions: [String?] = []
            var prices: [[Price]] = []
            var thumbnailImages: [String?] = []
            
            $0.menus.forEach {
                names.append($0.name)
                descriptions.append($0.description)
                prices.append($0.prices)
                thumbnailImages.append($0.thumbnailImage)
            }
            self.names.append(names)
            self.descriptions.append(descriptions)
            self.prices.append(prices)
            self.thumbnailImages.append(thumbnailImages)
        }
        reloadData()
    }
}

extension ShopDetailMenuGroupTableView {
    // numberOf
    func numberOfSections(in tableView: UITableView) -> Int {
        return names.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names[section].count
    }
    // viewFor, cellFor
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ShopDetailMenuGroupTableViewHeaderView.identifier) as? ShopDetailMenuGroupTableViewHeaderView else {
            return UITableViewHeaderFooterView()
        }
        view.bind(groupName: menuGroupName[section])
        return view
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopDetailMenuGroupTableViewCell.identifier, for: indexPath) as? ShopDetailMenuGroupTableViewCell else {
            return UITableViewCell()
        }
        cell.bind(name: names[indexPath.section][indexPath.row],
                  description: descriptions[indexPath.section][indexPath.row],
                  prices: prices[indexPath.section][indexPath.row],
                  thumbnailImage: thumbnailImages[indexPath.section][indexPath.row],
                  isFirstRow: indexPath.row == 0,
                  isLastRow: names[indexPath.section].count - 1 == indexPath.row)
        return cell
        
    }
    // select, highlight
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    // height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
}

extension ShopDetailMenuGroupTableView {
    
    func setTableView() {
        dataSource = self
        delegate = self
        register(ShopDetailMenuGroupTableViewCell.self, forCellReuseIdentifier: ShopDetailMenuGroupTableViewCell.identifier)
        register(ShopDetailMenuGroupTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: ShopDetailMenuGroupTableViewHeaderView.identifier)
    }
    
}

