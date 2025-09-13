//
//  OrderHistoryColletionView.swift
//  koin
//
//  Created by 김성민 on 9/8/25.
//

import UIKit
import SnapKit

final class OrderHistoryCollectionView: UICollectionView {

    struct Item: Hashable {
        let id: Int
        let stateText: String
        let dateText: String
        let storeName: String
        let menuName: String
        let priceText: String
        let imageURL: URL?
        let canReorder: Bool
    }

    var onSelect: ((Int) -> Void)?
    var onTapReorder: ((Int) -> Void)?
    var onReachEnd: (() -> Void)?


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
        
 
        
        register(OrderHistoryColletionViewCell.self,
                 forCellWithReuseIdentifier: OrderHistoryColletionViewCell.orderHistoryIdentifier)
    }

    func update(_ items: [Item]) {
        self.items = items
        reloadData()
    }
    
    func append(_ more: [Item]) {
        guard !more.isEmpty else { return }
        let start = items.count
        items.append(contentsOf: more)
        let indexPaths = (start..<(start + more.count)).map { IndexPath(item: $0, section: 0) }
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
        let item = items[indexPath.item]
        var image: UIImage? = UIImage.appImage(asset: .defaultMenuImage)
        
        if let url = item.imageURL {
            URLSession.shared.dataTask(with: url){ [weak collectionView] data, _, _ in
                guard let data, let image = UIImage(data: data)
                else {return}
                DispatchQueue.main.async{
                    if let visible = collectionView?.cellForItem(at: indexPath) as? OrderHistoryColletionViewCell {
                        visible.configure(
                            stateText: item.stateText,
                            dateText: item.dateText,
                            image: image,
                            storeName: item.storeName,
                            menuName: item.menuName,
                            priceText: item.priceText,
                            canReorder: item.canReorder
                        )
                    }
                }
            }.resume()
        }
        cell.configure(
            stateText: item.stateText,
            dateText: item.dateText,
            image: image,
            storeName: item.storeName,
            menuName: item.menuName,
            priceText: item.priceText,
            canReorder: item.canReorder
        )
        cell.onTapReorder = { [weak self] in
            self?.onTapReorder?(item.id)
        }
        return cell
    }
}

extension OrderHistoryCollectionView: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(items[indexPath.item].id)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 48
        let height = calculateHeight()
        return CGSize(width: width, height: height)
    }
}
    



extension OrderHistoryCollectionView.Item {
    init(from viewModel: OrderViewModel.OrderItem) {
        self.init(
            id: viewModel.id,
            stateText: viewModel.stateText,
            dateText: viewModel.dateText,
            storeName: viewModel.storeName,
            menuName: viewModel.menuName,
            priceText: viewModel.priceText,
            imageURL: viewModel.imageURL,
            canReorder: viewModel.canReorder
        )
    }
}

    

