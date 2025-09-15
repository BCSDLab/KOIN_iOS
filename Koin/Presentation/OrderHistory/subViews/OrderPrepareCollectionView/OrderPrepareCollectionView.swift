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
    
    struct Item: Hashable {
        let id: Int
        let paymentId: Int
        let methodText: String
        let estimatedTimeText: String
        let explanationText: String
        let imageURL: URL?
        let storeName: String
        let menuName: String
        let priceText: String
        let status: OrderInProgressStatus
    }
    
    private var items: [Item] = []
    
    
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
    
    func update(_ items: [Item]) {
        self.items = items
        reloadData()
        onLoadedIDs?(items.map { $0.id })
    }
    
    private func calculateHeight(for item: Item) -> CGFloat{
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

        let item = items[indexPath.item]
        var image: UIImage? = UIImage.appImage(asset: .defaultMenuImage)

        if let url = item.imageURL {
            URLSession.shared.dataTask(with: url) { [weak collectionView] data, _, _ in
                guard let data, let fetched = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    if let visible = collectionView?.cellForItem(at: indexPath) as? OrderPrepareCollectionViewCell {
                        visible.configure(
                            methodText: item.methodText,
                            estimatedTimeText: item.estimatedTimeText,
                            explanationText: item.explanationText,
                            image: fetched,
                            storeName: item.storeName,
                            menuName: item.menuName,
                            priceText: item.priceText,
                            status: item.status
                        )
                    }
                }
            }.resume()
        }
        cell.configure(
            methodText: item.methodText,
            estimatedTimeText: item.estimatedTimeText,
            explanationText: item.explanationText,
            image: image,
            storeName: item.storeName,
            menuName: item.menuName,
            priceText: item.priceText,
            status: item.status
        )
        
        cell.onTapOrderDetailButton = { [weak self] in
            self?.onTapOrderDetailButton?(item.paymentId)
        }
        
        return cell
    }

}

extension OrderPrepareCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.item]
        let width = UIScreen.main.bounds.width - 48
        let height = calculateHeight(for: item)
        return CGSize(width: width, height: height)
    }
    
}


extension OrderPrepareCollectionView.Item {
    init(from viewModel: OrderHistoryViewModel.PreparingItem) {
        self.init(
            id: viewModel.id,
            paymentId: viewModel.paymentId,
            methodText: viewModel.methodText,
            estimatedTimeText: viewModel.estimatedTimeText,
            explanationText: viewModel.explanationText,
            imageURL: viewModel.imageURL,
            storeName: viewModel.storeName,
            menuName: viewModel.menuName,
            priceText: viewModel.priceText,
            status: viewModel.status
        )
    }
}
