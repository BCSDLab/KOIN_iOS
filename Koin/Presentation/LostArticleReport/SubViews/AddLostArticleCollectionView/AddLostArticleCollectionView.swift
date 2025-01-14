//
//  AddLostArticleCollectionView.swift
//  koin
//
//  Created by 김나훈 on 1/13/25.
//

import Combine
import UIKit

final class AddLostArticleCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var footerCancellables = Set<AnyCancellable>()
    let heightChangedPublisher = PassthroughSubject<Void, Never>()
    let uploadImageButtonPublisher = PassthroughSubject<Int, Never>()
    private var somethings: [(Int, [String])] = [] {
        didSet {
            reloadData()
            collectionViewLayout.invalidateLayout()
            heightChangedPublisher.send()
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionHeadersPinToVisibleBounds = true
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        isScrollEnabled = false
        register(AddLostArticleCollectionViewCell.self, forCellWithReuseIdentifier: AddLostArticleCollectionViewCell.identifier)
        register(AddLostArticleFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AddLostArticleFooterView.identifier)
        dataSource = self
        delegate = self
        somethings.append((0, []))
        
    }
    
    func setUpSomethings() {
    }
    
    func addImageUrl(url: String, index: Int) {
        somethings[index].1.append(url)
    }

}

extension AddLostArticleCollectionView {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let estimatedHeight: CGFloat = 1500
        let dummyCell = AddLostArticleCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
        dummyCell.configure(text: "", index: 0, isSingle: true)
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: width, height: estimatedSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return somethings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return somethings.count >= 3 ? .zero : CGSize(width: collectionView.bounds.width, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddLostArticleFooterView.identifier, for: indexPath) as? AddLostArticleFooterView else {
                return UICollectionReusableView()
            }
            footerCancellables.removeAll()
            footerView.addItemButtonPublisher.sink { [weak self] in
                self?.somethings.append((1, []))
            }.store(in: &footerCancellables)
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddLostArticleCollectionViewCell.identifier, for: indexPath) as? AddLostArticleCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: String(somethings[indexPath.row].0), index: indexPath.row, isSingle: somethings.count < 2)
        cell.setImage(url: somethings[indexPath.row].1)
        cell.deleteButtonPublisher.sink { [weak self] _ in
            self?.somethings.remove(at: indexPath.row)
        }.store(in: &cell.cancellables)
        cell.addImageButtonPublisher.sink { [weak self] _ in
            self?.uploadImageButtonPublisher.send(indexPath.row)
        }.store(in: &cell.cancellables)
        return cell
    }
}
