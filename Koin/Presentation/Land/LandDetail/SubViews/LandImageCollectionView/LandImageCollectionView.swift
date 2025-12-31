//
//  LandImageCollectionView.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Combine
import UIKit

final class LandImageCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var imageList: [String] = []
    let indexPublisher = PassthroughSubject<String, Never>()
    private var currentIndex: Int {
        let visibleRect = CGRect(origin: self.contentOffset, size: self.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = self.indexPathForItem(at: visiblePoint)
        return visibleIndexPath?.row ?? 0
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(LandImageCollectionViewCell.self, forCellWithReuseIdentifier: LandImageCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func setImageList(_ list: [String]) {
        imageList = list
        indexPublisher.send("\(1)/\(imageList.count)")
        self.reloadData()
    }
    func scrollToPreviousItem() {
        let previousIndex = max(currentIndex - 1, 0)
        let indexPath = IndexPath(item: previousIndex, section: 0)
        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollToNextItem() {
        let nextIndex = min(currentIndex + 1, self.numberOfItems(inSection: 0) - 1)
        let indexPath = IndexPath(item: nextIndex, section: 0)
        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension LandImageCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LandImageCollectionViewCell.identifier, for: indexPath) as? LandImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageItem = imageList[indexPath.row]
        cell.configure(imageString: imageItem)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = (scrollView.contentOffset.x + scrollView.contentInset.left) / width
        let roundedIndex = round(index)
        let cellIndex = Int(roundedIndex)
        
        indexPublisher.send("\(cellIndex+1)/\(imageList.count)")
    }
}
