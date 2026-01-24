//
//  AddLostArticleCollectionView.swift
//  koin
//
//  Created by 김나훈 on 1/13/25.
//

import Combine
import UIKit

final class AddLostItemCollectionView: UICollectionView {
    
    // MARK: - Properties
    private var footerCancellables = Set<AnyCancellable>()
    let uploadImageButtonPublisher = PassthroughSubject<Int, Never>()
    let shouldDismissKeyBoardPublisher = PassthroughSubject<Void, Never>()
    let logPublisher = PassthroughSubject<(EventLabelType, EventParameter.EventCategory, Any), Never>()
    
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
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(AddLostItemCollectionViewCell.self, forCellWithReuseIdentifier: AddLostItemCollectionViewCell.identifier)
        register(AddLostItemHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AddLostItemHeaderView.identifier)
        register(AddLostItemFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AddLostItemFooterView.identifier)
        dataSource = self
        delegate = self
        
        let formattedDate: String = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일"
            return formatter.string(from: Date())
        }()
        articles.append(PostLostItemRequest(type: .found, category: "", location: "", foundDate: formattedDate, content: "", images: [], registeredAt: "", updatedAt: ""))
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
    
    func dismissDatePicker(_ currentIndexPath: IndexPath?) {
        for row in 0..<numberOfItems(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            if indexPath != currentIndexPath {
                (cellForItem(at: indexPath) as? AddLostItemCollectionViewCell)?.dismissDropdown()
            }
        }
    }
    
    func firstResponder() -> UIView? {
        var addLostItemCollectionViewCells: [AddLostItemCollectionViewCell] = []
        
        for row in 0..<numberOfItems(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = cellForItem(at: indexPath) as? AddLostItemCollectionViewCell {
                addLostItemCollectionViewCells.append(cell)
            }
        }
        
        return addLostItemCollectionViewCells.first { $0.hasFirstResponder() }?.firstResponder()
    }
}

extension AddLostItemCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddLostItemCollectionViewCell.identifier, for: indexPath) as? AddLostItemCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(index: indexPath.row, isSingle: articles.count < 2, model: articles[indexPath.row], type: type)
        cell.setImage(url: articles[indexPath.row].images ?? [])
        cell.deleteButtonPublisher.sink { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self?.articles.remove(at: indexPath.row)
                self?.reloadData()
            }
        }.store(in: &cell.cancellables)
        cell.addImageButtonPublisher.sink { [weak self] _ in
            self?.uploadImageButtonPublisher.send(indexPath.row)
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
        cell.shouldDismissDropDownPublisher.sink { [weak self] indexPath in
            self?.dismissDatePicker(indexPath)
        }.store(in: &cell.cancellables)
        cell.shouldDismissKeyBoardPublisher.sink { [weak self] in
            self?.shouldDismissKeyBoardPublisher.send()
        }.store(in: &cell.cancellables)
        cell.focusDropdownPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] targetView in
            var rect = targetView.convert(targetView.bounds, to: self)
            rect.size.height += 15
            self?.scrollRectToVisible(rect, animated: true)
        }.store(in: &cell.cancellables)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddLostItemHeaderView.identifier, for: indexPath) as? AddLostItemHeaderView else {
                return UICollectionReusableView()
            }
            headerView.configure(type: type)
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddLostItemFooterView.identifier, for: indexPath) as? AddLostItemFooterView else {
                return UICollectionReusableView()
            }
            footerCancellables.removeAll()
            footerView.addItemButtonPublisher.sink { [weak self] in
                guard let strongSelf = self else { return }
                let formattedDate: String = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy년 M월 d일"
                    return formatter.string(from: Date())
                }()
                self?.dismissDatePicker(nil)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self?.articles.append(PostLostItemRequest(type: .found, category: "", location: "", foundDate: formattedDate, content: "", images: [], registeredAt: "", updatedAt: ""))
                    self?.reloadData()
                }
                switch strongSelf.type {
                case .found: self?.logPublisher.send((EventParameter.EventLabel.Campus.findUserAddItem, .click, "물품 추가"))
                case .lost: self?.logPublisher.send((EventParameter.EventLabel.Campus.lostItemAddItem, .click, "물품 추가"))
                }
            }.store(in: &footerCancellables)
            footerView.shouldDismissDropDownPublisher.sink { [weak self] in
                self?.dismissDatePicker(nil)
            }.store(in: &footerCancellables)
            return footerView
        }
        return UICollectionReusableView()
    }}
    
extension AddLostItemCollectionView: UICollectionViewDelegateFlowLayout {
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return articles.count >= 10 ? .zero : CGSize(width: collectionView.bounds.width, height: 70)
    }
}
