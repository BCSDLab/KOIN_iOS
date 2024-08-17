//
//  PageControlCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Combine
import UIKit

final class PageControlCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    private var pageNumbers: NoticeListPages = .init(isPreviousPage: .previousPage, pages: [], selectedIndex: 0, isNextPage: .nextPage)
    var pageReloadPublisher = PassthroughSubject<([Int], PageReloadDirection), Never>()
    var selectPagePublisher = PassthroughSubject<Int, Never>()
    private var subscribtions = Set<AnyCancellable>()
    
    //MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(NoticeKeyWordCollectionViewCell.self, forCellWithReuseIdentifier: NoticeKeyWordCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
}


extension PageControlCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageNumbers.pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageControlCollectionViewCell.identifier, for: indexPath) as? PageControlCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.row == pageNumbers.selectedIndex {
            cell.configure(page: "\(pageNumbers.pages[indexPath.row])", isSelected: true)
        }
        else {
            cell.configure(page: "\(pageNumbers.pages[indexPath.row])", isSelected: false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       
        guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PageControlHeaderFooterView.identifier, for: indexPath) as? PageControlHeaderFooterView else {
            return UICollectionReusableView()
        }
        
        if kind == UICollectionView.elementKindSectionHeader {
            if let previousPage = pageNumbers.isPreviousPage {
                supplementaryView.updateButton(text: previousPage.rawValue)
            }
            supplementaryView.pageControlReloadPublisher.sink { [weak self] in
                guard let self = self else { return }
                self.pageReloadPublisher.send((self.pageNumbers.pages, .previousPage))
            }.store(in: &subscribtions)
        }
        else if kind == UICollectionView.elementKindSectionFooter {
            if let nextPage = pageNumbers.isNextPage {
                supplementaryView.updateButton(text: nextPage.rawValue)
            }
            supplementaryView.pageControlReloadPublisher.sink { [weak self] in
                guard let self = self else { return }
                self.pageReloadPublisher.send((self.pageNumbers.pages, .nextPage))
            }.store(in: &subscribtions)
        }
        return supplementaryView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectPagePublisher.send(indexPath.row)
    }
}

extension PageControlCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 32, height: 31)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if pageNumbers.isPreviousPage != nil {
            return CGSize(width: 32, height: 31)
        }
        else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if pageNumbers.isNextPage != nil {
            return CGSize(width: 32, height: 31)
        }
        else {
            return CGSize(width: 0, height: 0)
        }
    }
}

