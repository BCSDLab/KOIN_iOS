//
//  AddLostArticleCollectionView.swift
//  koin
//
//  Created by 김나훈 on 1/13/25.
//

import Combine
import UIKit

final class AddLostItemCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    let heightChangedPublisher = PassthroughSubject<Void, Never>()
    let uploadImageButtonPublisher = PassthroughSubject<Int, Never>()
    let dateButtonPublisher = PassthroughSubject<Void, Never>()
    let textViewFocusPublisher = PassthroughSubject<CGFloat, Never>()
    let textFieldFocusPublisher = PassthroughSubject<CGFloat, Never>()
    let logPublisher = PassthroughSubject<(EventLabelType, EventParameter.EventCategory, Any), Never>()
    
    private var footerCancellables = Set<AnyCancellable>()
    
    private var type: LostItemType = .lost
    private var articles: [PostLostItemRequest] = []
    
    // MARK: - Initializer
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
}

extension AddLostItemCollectionView {
    
    func setType(type: LostItemType) {
        self.type = type
        reloadData()
    }
    func addImageUrl(url: String, index: Int) {
        articles[index].images?.append(url)
        reloadData()
        collectionViewLayout.invalidateLayout()
    }
    
    func dismissKeyBoardDatePicker() {
        self.endEditing(true) // 키보드 닫기
        for row in 0..<numberOfItems(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            (cellForItem(at: indexPath) as? AddLostItemCollectionViewCell)?.dismissDropdown()
        }
    }
    private func dismissKeyDatePicker() {
        for row in 0..<numberOfItems(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            (cellForItem(at: indexPath) as? AddLostItemCollectionViewCell)?.dismissDropdown()
        }
    }
}

extension AddLostItemCollectionView {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let estimatedHeight: CGFloat = 1500
        let dummyCell = AddLostItemCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
        dummyCell.configure(index: 0, isSingle: true, model: PostLostItemRequest(type: .found, category: "", location: "", foundDate: "", content: "", registeredAt: "", updatedAt: ""), type: type)
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
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddLostItemFooterView.identifier, for: indexPath) as? AddLostItemFooterView else {
                return UICollectionReusableView()
            }
            footerCancellables.removeAll()
            footerView.addItemButtonPublisher.sink { [weak self] in
                guard let strongSelf = self else { return }
                self?.articles.append(PostLostItemRequest(type: .found, category: "", location: "", foundDate: "", content: "", images: [], registeredAt: "", updatedAt: ""))
                self?.reloadData()
                self?.collectionViewLayout.invalidateLayout()
                self?.heightChangedPublisher.send()
                switch strongSelf.type {
                case .found: self?.logPublisher.send((EventParameter.EventLabel.Campus.findUserAddItem, .click, "물품 추가"))
                case .lost: self?.logPublisher.send((EventParameter.EventLabel.Campus.lostItemAddItem, .click, "물품 추가"))
                }
            }.store(in: &footerCancellables)
            footerView.shouldDismissDropDownPublisher.sink { [weak self] in
                self?.dismissKeyDatePicker()
            }.store(in: &footerCancellables)
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddLostItemCollectionViewCell.identifier, for: indexPath) as? AddLostItemCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(index: indexPath.row, isSingle: articles.count < 2, model: articles[indexPath.row], type: type)
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
        /*
         cell.dateButtonPublisher.sink { [weak self] _ in
            self?.dateButtonPublisher.send()
         }.store(in: &cell.cancellables)
        */
        cell.textFieldFocusPublisher.sink { [weak self] value in
            self?.textFieldFocusPublisher.send(value)
        }.store(in: &cell.cancellables)
        cell.textViewFocusPublisher.sink { [weak self] value in
            self?.textViewFocusPublisher.send(value)
        }.store(in: &cell.cancellables)
        cell.datePublisher.sink { [weak self] value in
            self?.articles[indexPath.row].foundDate = value
        }.store(in: &cell.cancellables)
        cell.categoryPublisher.sink { [weak self] value in
            guard let strongSelf = self else { return }
            self?.articles[indexPath.row].category = value
            switch strongSelf.type {
            case .found: self?.logPublisher.send((EventParameter.EventLabel.Campus.findUserCategory, .click, value))
            case .lost: self?.logPublisher.send((EventParameter.EventLabel.Campus.lostItemCategory, .click, value))
            }
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
        cell.shouldDismissDropDownPublisher.sink { [weak self] in
            self?.dismissKeyDatePicker()
        }.store(in: &cell.cancellables)
        return cell
    }
}

extension AddLostItemCollectionView {
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        isScrollEnabled = false
        register(AddLostItemCollectionViewCell.self, forCellWithReuseIdentifier: AddLostItemCollectionViewCell.identifier)
        register(AddLostItemFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AddLostItemFooterView.identifier)
        dataSource = self
        delegate = self
        articles.append(PostLostItemRequest(type: .found, category: "", location: "", foundDate: "", content: "", images: [], registeredAt: "", updatedAt: ""))
    }
}
