//
//  ShopSearchTableView.swift
//  koin
//
//  Created by 홍기정 on 11/8/25.
//

import UIKit
import Combine

final class ShopSearchTableView: UITableView {
    
    // MARK: - Properties
    private var shopNameSearchResult: [ShopNameSearchResult] = []
    private var menuNameSearchResult: [MenuNameSearchResult] = []
    private let navigatePublisher = PassthroughSubject<Int, Never>()
    
    // MARK: - Initializer
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        separatorStyle = .none
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShopSearchTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        deselectRow(at: indexPath, animated: true)
        
        let shopId: Int = {
            switch indexPath.section {
            case 0:
                return shopNameSearchResult[indexPath.row].shopID
            default:
                return menuNameSearchResult[indexPath.row].shopID
            }
        }()
        navigatePublisher.send(shopId)
    }
}

extension ShopSearchTableView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return shopNameSearchResult.count
        case 1: return menuNameSearchResult.count
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopSearchTableViewShopNameCell.identifier, for: indexPath) as? ShopSearchTableViewShopNameCell else {
                return UITableViewCell()
            }
            cell.configure(shopName: shopNameSearchResult[indexPath.row].shopName)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopSearchTableViewMenuNameCell.identifier, for: indexPath) as? ShopSearchTableViewMenuNameCell else {
                return UITableViewCell()
            }
            cell.configure(menuName: menuNameSearchResult[indexPath.row].menuName,
                           shopName: menuNameSearchResult[indexPath.row].shopName)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
}

extension ShopSearchTableView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        register(ShopSearchTableViewShopNameCell.self, forCellReuseIdentifier: ShopSearchTableViewShopNameCell.identifier)
        register(ShopSearchTableViewMenuNameCell.self, forCellReuseIdentifier: ShopSearchTableViewMenuNameCell.identifier)
        rowHeight = 48
    }
}
