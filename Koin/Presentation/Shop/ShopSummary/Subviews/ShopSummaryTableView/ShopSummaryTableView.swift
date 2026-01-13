//
//  ShopSummaryTableView.swift
//  koin
//
//  Created by 홍기정 on 9/8/25.
//

import UIKit
import Combine

final class ShopSummaryTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    private var menuGroupName: [String] = []
    private var ids: [[Int]] = []
    private var names: [[String]] = []
    private var descriptions: [[String?]] = []
    private var thumbnailImages: [[String?]] = []
    private var isSoldOuts: [[Bool]] = []
    private var prices: [[[Price]]] = []
    
    private var navigationBarHeight: CGFloat = 0
    
    let didTapCellPublisher = PassthroughSubject<Int, Never>()
    let updateNavigationBarPublisher = PassthroughSubject<(UIColor, CGFloat), Never>()
    let shouldShowStickyPublisher = PassthroughSubject<Bool, Never>()
    let shouldSetContentInsetPublisher = PassthroughSubject<Bool, Never>()
    let didEndScrollPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Initializer
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ orderShopMenus: [OrderShopMenus]) {
        orderShopMenus.forEach {
            self.menuGroupName.append($0.menuGroupName)
            
            var ids: [Int] = []
            var names: [String] = []
            var descriptions: [String?] = []
            var thumbnailImages: [String?] = []
            var isSoldOuts: [Bool] = []
            var prices: [[Price]] = []
            
            $0.menus.forEach {
                ids.append($0.id)
                names.append($0.name)
                descriptions.append($0.description)
                thumbnailImages.append($0.thumbnailImage)
                isSoldOuts.append($0.isSoldOut)
                prices.append($0.prices)
            }
            self.ids.append(ids)
            self.names.append(names)
            self.descriptions.append(descriptions)
            self.thumbnailImages.append(thumbnailImages)
            self.isSoldOuts.append(isSoldOuts)
            self.prices.append(prices)
        }
        reloadData()
    }
    func configure(navigationBarHeight: CGFloat) {
        self.navigationBarHeight = navigationBarHeight
    }
}

extension ShopSummaryTableView {
    // numberOf
    func numberOfSections(in tableView: UITableView) -> Int {
        return names.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names[section].count
    }
    // viewFor, cellFor
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ShopSummaryTableViewHeaderView.identifier) as? ShopSummaryTableViewHeaderView else {
            return UITableViewHeaderFooterView()
        }
        view.configure(groupName: menuGroupName[section])
        return view
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopSummaryTableViewCell.identifier, for: indexPath) as? ShopSummaryTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(name: names[indexPath.section][indexPath.row],
                  description: descriptions[indexPath.section][indexPath.row],
                  prices: prices[indexPath.section][indexPath.row],
                  thumbnailImage: thumbnailImages[indexPath.section][indexPath.row],
                  isFirstRow: indexPath.row == 0,
                  isLastRow: names[indexPath.section].count - 1 == indexPath.row,
                  isSoldOut: isSoldOuts[indexPath.section][indexPath.row])
        return cell
        
    }
    // select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didTapCellPublisher.send(ids[indexPath.section][indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension ShopSummaryTableView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let navigationBarOffset = frame.width/1.21 - (self.navigationBarHeight + UIApplication.topSafeAreaHeight())
        let stickyOffset: CGFloat = (tableHeaderView?.frame.height ?? 0) - (self.navigationBarHeight + UIApplication.topSafeAreaHeight() + 66)
        let contentOffset = self.contentOffset.y
        
        var opacity = 1 - (navigationBarOffset - contentOffset)/100
        opacity = max(0, min(opacity, 1))
        let color = UIColor(white: (1 - opacity), alpha: 1)
        let shouldShowSticky = stickyOffset <= contentOffset
        
        self.updateNavigationBarPublisher.send((color, CGFloat(opacity)))
        self.shouldShowStickyPublisher.send(shouldShowSticky)
        self.shouldSetContentInsetPublisher.send(shouldShowSticky)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            didEndScrollPublisher.send()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndScrollPublisher.send()
    }
}

extension ShopSummaryTableView {
    
    private func commonInit() {
        dataSource = self
        delegate = self
        register(ShopSummaryTableViewCell.self, forCellReuseIdentifier: ShopSummaryTableViewCell.identifier)
        register(ShopSummaryTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: ShopSummaryTableViewHeaderView.identifier)
    }
}

