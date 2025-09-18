//
//  OrderPrepareCollectionView.swift
//  koin
//
//  Created by 김성민 on 9/9/25.
//

import UIKit

final class OrderPrepareCollectionView: UICollectionView {
    
    var onLoadedIDs: (([Int]) -> Void)?
    var onTapOrderDetailButton: ((Int) -> Void)?
    
    private var items: [OrderInProgress] = []
    
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); commonInit() }
    
    private func commonInit() {
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        dataSource = self
        delegate = self
        
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .zero
        }
        
        register(OrderPrepareCollectionViewCell.self,
                 forCellWithReuseIdentifier: OrderPrepareCollectionViewCell.OrderPrepareIdentifier)
    }
    
    func update(_ items: [OrderInProgress]) {
        self.items = items
        reloadData()
        onLoadedIDs?(items.map { $0.id })
    }
    
    private func calculateHeight(for item: OrderInProgress) -> CGFloat{
        let isEmptyContent = !item.estimatedTimeText
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let showEstimateTimeLabel = item.status.showEstimatedTime && isEmptyContent
        
        let topInset: CGFloat = 16
        let chipH: CGFloat = 24
        let topState: CGFloat = 12
        let stateH: CGFloat = 32
        let estimateTimeH: CGFloat   = 32
        let explainH: CGFloat = 19
        let underlineTop: CGFloat = 16
        let underlineH: CGFloat = 1
        let imageTop: CGFloat = 16
        let imageH: CGFloat = 88
        let buttonTop: CGFloat = 16
        let buttonH: CGFloat = 44
        let bottomInset: CGFloat = 16
        
        var total = topInset + chipH + topState + stateH + explainH + underlineTop + underlineH + imageTop + imageH + buttonTop + buttonH + bottomInset
        if showEstimateTimeLabel { total += estimateTimeH }
        return total
    }
}
    

extension OrderPrepareCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OrderPrepareCollectionViewCell.OrderPrepareIdentifier,
            for: indexPath
        ) as? OrderPrepareCollectionViewCell else {
            return UICollectionViewCell()
        }
        let order = items[indexPath.item]
        cell.configure(with: order)

        cell.onTapOrderDetailButton = { [weak self] in
            self?.onTapOrderDetailButton?(order.paymentId)
        }
        return cell
    }

}

extension OrderPrepareCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.item]
        let width = UIScreen.main.bounds.width - 48
        let height = calculateHeight(for: item)
        return CGSize(width: width, height: height)
    }
}
