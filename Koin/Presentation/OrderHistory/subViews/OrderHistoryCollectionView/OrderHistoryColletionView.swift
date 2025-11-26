//
//  OrderHistoryColletionView.swift
//  koin
//
//  Created by 김성민 on 9/8/25.
//

import UIKit
import SnapKit

final class OrderHistoryCollectionView: UICollectionView {
    
    private var items: [OrderHistory] = []
    
    var onSelect: ((Int) -> Void)?
    var onTapReorder: ((Int) -> Void)?
    var onTapOrderInfoButton: ((Int) -> Void)?
    var onReachEnd: (() -> Void)?
    var onDidScroll: ((CGFloat) -> Void)?
    
    
    
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        dataSource = self
        delegate = self
        
        register(OrderHistoryColletionViewCell.self,
                 forCellWithReuseIdentifier: OrderHistoryColletionViewCell.orderHistoryIdentifier)
    }
    
    func update(_ items: [OrderHistory]) {
        self.items = items
        reloadData()
    }
    
    func append(_ nextItem: [OrderHistory]) {
        guard !nextItem.isEmpty else { return }
        let start = items.count
        items.append(contentsOf: nextItem)
        let indexPaths = (start..<(start + nextItem.count)).map { IndexPath(item: $0, section: 0) }
        performBatchUpdates({ insertItems(at: indexPaths) }, completion: nil)
    }
    
    
    private func calculateHeight() -> CGFloat{
        let topInset: CGFloat = 16
        let stateLabelH = UIFont.appFont(.pretendardBold, size: 16).lineHeight
        let underLineInset: CGFloat = 12
        let underLineH: CGFloat = 1
        let menuImageTop: CGFloat = 12
        let menuImageH: CGFloat = 88
        let reviewButtonTop: CGFloat = 16
        let reviewButton: CGFloat = 44
        let reorderButtonTop: CGFloat = 12
        let reorderButton: CGFloat = 44
        let bottomInset: CGFloat = 16
        
        return topInset + stateLabelH + underLineInset + underLineH + menuImageTop + menuImageH + reviewButtonTop + reviewButton + reorderButtonTop + reorderButton + bottomInset
    }
}

extension OrderHistoryCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderHistoryColletionViewCell.orderHistoryIdentifier, for: indexPath) as? OrderHistoryColletionViewCell else {
            return UICollectionViewCell()
        }
        let order = items[indexPath.item]
        cell.configure(with: order)
        
        cell.onTapReorder = { [weak self] in
            self?.onTapReorder?(order.id)
        }
        cell.onTapOrderInfoButton = { [weak self] in
            self?.onTapOrderInfoButton?(order.paymentId)
        }
        return cell
    }
}

extension OrderHistoryCollectionView: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(items[indexPath.item].id)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onDidScroll?(scrollView.contentOffset.y)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 48
        let height = calculateHeight()
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !items.isEmpty else { return }
        if indexPath.item == items.count - 1 {
            onReachEnd?()
        }
    }
    
}
