//
//  EventListCollectionView.swift
//  koin
//
//  Created by 김나훈 on 4/11/24.
//

import Combine
import UIKit

final class EventListCollectionView: UICollectionView, UICollectionViewDataSource {
    
    private var eventList: [ShopEvent] = []
    var buttonTappedPublisher = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    var heightChanged: (() -> Void)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(EventListCollectionViewCell.self, forCellWithReuseIdentifier: EventListCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func setEventList(_ list: [ShopEvent]) {
        eventList = list
        self.reloadData()
    }
    
}

extension EventListCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           if let cell = collectionView.cellForItem(at: indexPath) as? EventListCollectionViewCell, cell.isExpanded {
               return calculateDynamicCellHeight(at: indexPath, width: collectionView.frame.width, collectionView)
           } else {
               return CGSize(width: collectionView.frame.width, height: 100) 
           }
       }
    
    private func calculateDynamicCellHeight(at indexPath: IndexPath, width: CGFloat, _ collectionView: UICollectionView) -> CGSize {
        let eventItem = eventList[indexPath.row]

        let tempLabel = UILabel()
        tempLabel.numberOfLines = 0
        tempLabel.font = UIFont.appFont(.pretendardRegular, size: 14)
        let labelWidth = collectionView.frame.width - 48
        tempLabel.text = eventItem.content
        let size = tempLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let totalHeight = 10 + 363 + 16 + 21 + 12 + size.height + 6 + 12 + 10
        return CGSize(width: collectionView.frame.width, height: totalHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventListCollectionViewCell.identifier, for: indexPath) as? EventListCollectionViewCell else {
            return UICollectionViewCell()
        }
        let eventItem = eventList[indexPath.row]
        cell.configure(event: eventItem)
        
        return cell
    }
    
}
