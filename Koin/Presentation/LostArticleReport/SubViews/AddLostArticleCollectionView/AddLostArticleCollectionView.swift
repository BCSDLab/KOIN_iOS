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
    let dateButtonPublisher = PassthroughSubject<Void, Never>()
    let textViewFocusPublisher = PassthroughSubject<CGFloat, Never>()
    let logPublisher = PassthroughSubject<(EventLabelType, EventParameter.EventCategory, Any), Never>()
    
    private var articles: [PostLostArticleRequest] = []
    
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
        articles.append(PostLostArticleRequest(category: "", location: "", foundDate: "", content: "", images: [], registeredAt: "", updatedAt: ""))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           tapGesture.cancelsTouchesInView = false  // Allows taps to pass through to collection view cells
           addGestureRecognizer(tapGesture)
    }
    
    
    func addImageUrl(url: String, index: Int) {
        articles[index].images?.append(url)
        reloadData()
        collectionViewLayout.invalidateLayout()
    }
    
    @objc private func dismissKeyboard() {
        
        self.endEditing(true)
    }

}

extension AddLostArticleCollectionView {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let estimatedHeight: CGFloat = 1500
        let dummyCell = AddLostArticleCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
        dummyCell.configure(index: 0, isSingle: true, model: PostLostArticleRequest(category: "", location: "", foundDate: "", content: "", registeredAt: "", updatedAt: ""))
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: width, height: estimatedSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return articles.count >= 10 ? .zero : CGSize(width: collectionView.bounds.width, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddLostArticleFooterView.identifier, for: indexPath) as? AddLostArticleFooterView else {
                return UICollectionReusableView()
            }
            footerCancellables.removeAll()
            footerView.addItemButtonPublisher.sink { [weak self] in
                self?.articles.append(PostLostArticleRequest(category: "", location: "", foundDate: "", content: "", images: [], registeredAt: "", updatedAt: ""))
                self?.reloadData()
                self?.collectionViewLayout.invalidateLayout()
                self?.heightChangedPublisher.send()
                self?.logPublisher.send((EventParameter.EventLabel.Campus.findUserAddItem, .click, "물품 추가"))
            }.store(in: &footerCancellables)
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddLostArticleCollectionViewCell.identifier, for: indexPath) as? AddLostArticleCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(index: indexPath.row, isSingle: articles.count < 2, model: articles[indexPath.row])
        cell.setImage(url: articles[indexPath.row].images ?? [])
        cell.deleteButtonPublisher.sink { [weak self] _ in
            self?.articles.remove(at: indexPath.row)
            self?.reloadData()
            self?.collectionViewLayout.invalidateLayout()
            self?.heightChangedPublisher.send()
        }.store(in: &cell.cancellables)
        cell.addImageButtonPublisher.sink { [weak self] _ in
            self?.uploadImageButtonPublisher.send(indexPath.row)
        }.store(in: &cell.cancellables)
        cell.dateButtonPublisher.sink { [weak self] _ in
            self?.dateButtonPublisher.send()
        }.store(in: &cell.cancellables)
        cell.textViewFocusPublisher.sink { [weak self] value in
            self?.textViewFocusPublisher.send(value)
        }.store(in: &cell.cancellables)
        cell.datePublisher.sink { [weak self] value in
            self?.articles[indexPath.row].foundDate = value
        }.store(in: &cell.cancellables)
        cell.categoryPublisher.sink { [weak self] value in
            self?.articles[indexPath.row].category = value
            self?.logPublisher.send((EventParameter.EventLabel.Campus.findUserCategory, .click, value))
        }.store(in: &cell.cancellables)
        cell.locationPublisher.sink { [weak self] value in
            self?.articles[indexPath.row].location = value
        }.store(in: &cell.cancellables)
        cell.contentPublisher.sink { [weak self] value in
            self?.articles[indexPath.row].content = value
        }.store(in: &cell.cancellables)
        cell.imageUrlsPublisher.sink { [weak self] urls in
            self?.articles[indexPath.row].images = urls
        }.store(in: &cell.cancellables)
        return cell
    }
}
