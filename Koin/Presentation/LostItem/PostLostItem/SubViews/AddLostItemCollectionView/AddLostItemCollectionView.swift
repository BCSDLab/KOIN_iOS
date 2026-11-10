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
    let logPublisher = PassthroughSubject<(LegacyEventLabelType, EventParameter.EventCategory, Any), Never>()
    
    private var type: LostItemType = .lost
    private var articles: [PostLostItemRequest] = []
    /// 화면 진입 시 1회 고정. 습득일 범위·기본값 기준
    private let now = Date()
    
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
        
        articles.append(PostLostItemRequest(type: .found, category: "", location: "", foundDate: now.string(with: .yearMonthDayHyphen), content: "", images: [], registeredAt: "", updatedAt: ""))
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
        cell.configure(index: indexPath.row, isSingle: articles.count < 2, model: articles[indexPath.row], type: type, now: now)
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
        cell.datePublisher.sink { [weak self] date in
            self?.articles[indexPath.row].foundDate = date.string(with: .yearMonthDayHyphen)
        }.store(in: &cell.cancellables)
        cell.categoryPublisher.sink { [weak self] value in
            guard let strongSelf = self else { return }
            self?.articles[indexPath.row].category = value
            switch strongSelf.type {
            case .found: self?.logPublisher.send((LegacyEventParameter.EventLabel.Campus.LostItem.findUserCategory, .click, value))
            case .lost: self?.logPublisher.send((LegacyEventParameter.EventLabel.Campus.LostItem.lostItemCategory, .click, value))
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
                let foundDate = strongSelf.now.string(with: .yearMonthDayHyphen)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self?.articles.append(PostLostItemRequest(type: .found, category: "", location: "", foundDate: foundDate, content: "", images: [], registeredAt: "", updatedAt: ""))
                    self?.reloadData()
                }
                switch strongSelf.type {
                case .found: self?.logPublisher.send((LegacyEventParameter.EventLabel.Campus.LostItem.findUserAddItem, .click, "물품 추가"))
                case .lost: self?.logPublisher.send((LegacyEventParameter.EventLabel.Campus.LostItem.lostItemAddItem, .click, "물품 추가"))
                }
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
        dummyCell.configure(index: indexPath.row, isSingle: articles.count < 2, model: articles[indexPath.row], type: type, now: now)
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
