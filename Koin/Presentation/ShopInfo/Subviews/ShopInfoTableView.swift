//
//  ShopInfoTableView.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit

final class ShopInfoTableView: UITableView {
    
    enum HighlightableCell {
        case name
        case deliveryTips
        case notice
    }
    
    // MARK: - Properties
    private var shopInfo: ShopInfo = ShopInfo.empty()
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
    
    func configure(shopInfo: ShopInfo, shouldHighlight: ShopInfoTableView.HighlightableCell) {
        self.shopInfo = shopInfo
        self.shouldHighlight = shouldHighlight
        reloadData()
    }
}

extension ShopInfoTableView {
    
    func scrollToHighlightedCell() {
        let indexPath = {
            switch shouldHighlight {
            case .name: return IndexPath(row: 0, section: 0)
            case .notice:  return IndexPath(row: 0, section: 2)
            case .deliveryTips:  return IndexPath(row: 0, section: 3)
            default:
                print("ShopInfoTableView error")
                return IndexPath(row: 0, section: 0)
            }
        }()
        scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

extension ShopInfoTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = ShopInfoTableViewNameCell()
            cell.configure(title: shopInfo.name, name: shopInfo.name, address: shopInfo.address, openTime: shopInfo.openTime, closeTime: shopInfo.closeTime, closedDays: shopInfo.closedDays, phone: shopInfo.phone)
            cell.backgroundColor = .appColor(shouldHighlight == .name ? .neutral100 : .neutral0)
            return cell
        case 1:
            let cell = ShopInfoTableViewIntroductionCell()
            cell.configure(title: "가게 소개", introduction: shopInfo.introduction)
            return cell
        case 2:
            let cell = ShopInfoTableViewNoticeCell()
            cell.configure(title: "가게 알림", notice: shopInfo.notice)
            cell.backgroundColor = .appColor(shouldHighlight == .notice ? .neutral100 : .neutral0)
            return cell
        case 3:
            let cell = ShopInfoTableViewDeliveryTipsCell()
            cell.configure(title: "주문금액별 총 배달팁", deliveryTips: shopInfo.deliveryTips)
            cell.backgroundColor = .appColor(shouldHighlight == .deliveryTips ? .neutral100 : .neutral0)
            return cell
        case 4:
            let cell = ShopInfoTableViewOwnerInfoCell()
            cell.configure(title: "사업자 정보", ownerInfo: shopInfo.ownerInfo)
            return cell
        case 5:
            let cell = ShopInfoTableViewOriginsCell()
            cell.configure(title: "원산지 표기", origins: shopInfo.origins)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension ShopInfoTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 48 + 154 + 6
        case 1: return 48 + 18 + 6
        case 2: return 48 + 18 + 6
        case 3: return 48 + 18 + 6
        case 4: return 48 + 124 + 6
        case 5: return 48 + 18 + 6
        default: return 0
        }
    }
}

extension ShopInfoTableView {
    
    private func commonInit() {
        dataSource = self
        delegate = self
    }
}

