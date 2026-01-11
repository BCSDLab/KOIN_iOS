//
//  ShopDetailTableView.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit

final class ShopDetailTableView: UITableView {
    
    enum HighlightableCell {
        case name
        case description
        case deliveryTips
    }
    
    // MARK: - Properties
    private var shopDetail: OrderShopDetail? = nil
    private var shouldHighlight: HighlightableCell?
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .plain)
        rowHeight = UITableView.automaticDimension
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(shopDetail: OrderShopDetail, shouldHighlight: ShopDetailTableView.HighlightableCell) {
        self.shopDetail = shopDetail
        self.shouldHighlight = shouldHighlight
        reloadData()
    }
}

extension ShopDetailTableView {
    
    func scrollToHighlightedCell() {
        let indexPath = {
            switch shouldHighlight {
            case .name:
                return IndexPath(row: 0, section: 0)
            case .description:
                return IndexPath(row: 0, section: 1)
            case .deliveryTips:
                return IndexPath(row: 0, section: 2)
            default:
                return IndexPath(row: 0, section: 0)
            }
        }()
        scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

extension ShopDetailTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let shopDetail else {
            return UITableViewCell()
        }
        switch indexPath.section {
        case 0:
            let cell = ShopDetailTableViewNameCell()
            cell.configure(title: shopDetail.name, name: shopDetail.name, address: shopDetail.address, openTime: shopDetail.openTime, closeTime: shopDetail.closeTime, closedDays: shopDetail.closedDays, phone: shopDetail.phone)
            cell.backgroundColor = .appColor(shouldHighlight == .name ? .neutral100 : .neutral0)
            return cell
        case 1:
            let cell = ShopDetailTableViewIntroductionCell()
            cell.configure(title: "가게 소개", introduction: shopDetail.introduction)
            cell.backgroundColor = .appColor(shouldHighlight == .description ? .neutral100 : .neutral0)
            return cell
        case 2:
            let cell = ShopDetailTableViewDeliveryTipsCell()
            cell.configure(title: "주문금액별 총 배달팁", deliveryTips: shopDetail.deliveryTips)
            cell.backgroundColor = .appColor(shouldHighlight == .deliveryTips ? .neutral100 : .neutral0)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension ShopDetailTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 48 + 154 + 6
        case 1: return 48 + 18 + 6
        case 2: return 48 + 18 + 6
        default: return 0
        }
    }
}

extension ShopDetailTableView {
    
    private func commonInit() {
        dataSource = self
        delegate = self
    }
}

