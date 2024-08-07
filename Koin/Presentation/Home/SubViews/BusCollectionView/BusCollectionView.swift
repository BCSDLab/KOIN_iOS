//
//  BusCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 1/19/24.
//

import Combine
import UIKit

final class BusCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var centerCellIndex: IndexPath? {
        didSet {
            if(oldValue != self.centerCellIndex) {
                departure = oldValue?.item ?? 0
                arrival = self.centerCellIndex?.item ?? 0
            }
        }
    }
    var departure: Int?
    var arrival: Int?
    var busTypePublisher = PassthroughSubject<BusType, Never>()
    let busRequestPublisher = PassthroughSubject<[String], Never>()
    let scrollPublisheer = PassthroughSubject<String, Never>()
    var subscriptions = Set<AnyCancellable>()
    private var busItems: [BusInformation] = [.init(busType: .cityBus, redirectedText: "시간표 보러가기", color: .success600), .init(busType: .shuttleBus, redirectedText: "유니버스 보러가기", color: .sub500), .init(busType: .expressBus, redirectedText: "시간표 보러가기", color: .bus2)]
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        dataSource = self
        delegate = self
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = true
        contentInset = .zero
        busItems = Array(repeating: busItems, count: 5).flatMap { $0 }
        register(BusCollectionViewCell.self, forCellWithReuseIdentifier: BusCollectionViewCell.identifier)
    }
}

extension BusCollectionView: UICollectionViewDelegateFlowLayout {
    
    func updateText(data: BusDTO) {
        guard let centerIndexPath = centerCellIndex, let centerCell = cellForItem(at: centerIndexPath) as? BusCollectionViewCell else {
            return
        }
        centerCell.updateText(data: data)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        
        if let newCenterCellIndex = self.indexPathForItem(at: center), newCenterCellIndex != centerCellIndex {
            centerCellIndex = newCenterCellIndex
            UIView.performWithoutAnimation {
                self.reloadItems(at: [newCenterCellIndex])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize(width: 100, height: 100) }
        
        if indexPath != centerCellIndex {
            return CGSize(width: layout.itemSize.width, height: layout.itemSize.height)
        } else {
            return CGSize(width: layout.itemSize.width, height: layout.itemSize.height)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            adjustScrollPosition()
            
        }
        if (departure ?? 0)%3 != (arrival ?? 0)%3 {
            scrollPublisheer.send("\(busItems[departure ?? 0].busType.rawValue)>\(busItems[arrival ?? 0].busType.rawValue)")
        }
    }

    private func adjustScrollPosition() {
        if let centerIndexPath = self.centerCellIndex {
            let adjustedIndex = (centerIndexPath.row % 3) + 6
            scrollToItem(at: IndexPath(row: adjustedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let cellWidth = layout.itemSize.width
        let cellSpacing = layout.minimumLineSpacing
        let adjustedCellWidth = cellWidth - 10
        let offsetAdjustment = (cellWidth - adjustedCellWidth) / 2
        
        let proposedContentOffset = targetContentOffset.pointee
        let rawIndex = (proposedContentOffset.x + offsetAdjustment + cellSpacing / 2) / (adjustedCellWidth + cellSpacing)
        let index = round(rawIndex)
        let adjustedIndex = max(0, min(CGFloat(busItems.count - 1), index)) // 범위 보정

        let newOffsetX = adjustedIndex * (adjustedCellWidth + cellSpacing) - scrollView.bounds.width / 2 + cellWidth / 2 + offsetAdjustment

        targetContentOffset.pointee.x = newOffsetX
    }


    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: self.contentOffset, size: self.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = self.indexPathForItem(at: visiblePoint) {
            if let cell = cellForItem(at: visibleIndexPath) as? BusCollectionViewCell {
                let data = cell.getBusType()
                busRequestPublisher.send(data)
            }
        }
        adjustScrollPosition()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusCollectionViewCell.identifier, for: indexPath) as? BusCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.buttonTappedAction = { [weak self] info in
            self?.busRequestPublisher.send(info)
        }
        
        cell.redirectBtnTappedAction = { [weak self] _ in
            self?.busTypePublisher.send(self?.busItems[indexPath.row].busType ?? .shuttleBus)
        }
        
        cell.configure(busType: busItems[indexPath.row].busType, redirectedText: busItems[indexPath.row].redirectedText, colorAsset: busItems[indexPath.row].color)
        return cell
    }
    
}

