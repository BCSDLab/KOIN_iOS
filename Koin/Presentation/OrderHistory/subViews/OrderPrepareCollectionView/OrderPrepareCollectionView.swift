//
//  OrderPrepareCollectionView.swift
//  koin
//
//  Created by 김성민 on 9/9/25.
//

import UIKit

final class OrderPrepareCollectionView: UICollectionView {
    
    var onLoadedIDs: (([Int]) -> Void)?

    struct Item: Hashable {
        let id: Int
        let methodText: String
        let estimatedTimeText: String
        let explanationText: String
        let imageURL: URL?
        let storeName: String
        let menuName: String
        let priceText: String
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

        register(OrderPrepareCollectionViewCell.self,
                 forCellWithReuseIdentifier: OrderPrepareCollectionViewCell.OrderPrepareIdentifier)
    }
    
    func update(_ items: [Item]) {
        self.items = items
        reloadData()
        onLoadedIDs?(items.map { $0.id })
    }
}

extension OrderPrepareCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
                            priceText: item.priceText
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
            priceText: item.priceText
        )
        return cell
    }

}

extension OrderPrepareCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])

    }
}


extension OrderPrepareCollectionView.Item {
    init(from viewModel: OrderViewModel.PreparingItem) {
        self.init(
            id: viewModel.id,
            methodText: viewModel.methodText,
            estimatedTimeText: viewModel.estimatedTimeText,
            explanationText: viewModel.explanationText,
            imageURL: viewModel.imageURL,
            storeName: viewModel.storeName,
            menuName: viewModel.menuName,
            priceText: viewModel.priceText
        )
    }
}

//extension OrderPrepareCollectionView: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: 299)
//    }
//}
