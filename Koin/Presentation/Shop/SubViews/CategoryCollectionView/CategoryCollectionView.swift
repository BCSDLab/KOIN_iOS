//
//  CategoryCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit

final class CategoryCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    private var subscriptions: Set<AnyCancellable> = []
    private var shopCategories: [ShopCategory] = []
    let cellTapPublisher = PassthroughSubject<Int, Never>()
    let selectedCategoryPublisher = CurrentValueSubject<Int, Never>(0)
    private var selectedId = 0
    private var isFooterEnabled: Bool = false // 기본값: 푸터 비활성화
    let publisher = PassthroughSubject<Void, Never>()
    private var headerCancellables = Set<AnyCancellable>()
       func enableFooter(_ isEnabled: Bool) {
           isFooterEnabled = isEnabled
           self.reloadData() // 레이아웃 갱신
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
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        register(CategoryFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CategoryFooterView.identifier)

        dataSource = self
        delegate = self
        //  collectionViewLayout = createLayout() // 새 레이아웃 설정
    }
    
    func updateCategories(_ categories: [ShopCategory]) {
        self.shopCategories = categories
        self.reloadData()
    }
    
    func updateCategory(_ id: Int) {
        selectedId = id
        for case let cell as CategoryCollectionViewCell in visibleCells {
            if let indexPath = indexPath(for: cell) {
                let category = shopCategories[indexPath.row]
                let isSelected = category.id == id
                cell.configure(info: category, isSelected)
            }
        }
        selectedCategoryPublisher.send(selectedId)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        
        
        let category = shopCategories[indexPath.row]
        if shopCategories.contains(where: { $0.id == -1 }) {
            cell.configure(info: category, false)
        } else {
            let isSelected = category.id == selectedId
            cell.configure(info: category, isSelected)
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shopCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = shopCategories[indexPath.row]
        selectedId = category.id
        cellTapPublisher.send(selectedId)
        reloadData()
    }
}

extension CategoryCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
          return isFooterEnabled ? CGSize(width: collectionView.bounds.width, height: 50) : .zero // 푸터 크기 지정 or 숨김
      }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            guard isFooterEnabled,
                  let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CategoryFooterView.identifier,
                    for: indexPath
                  ) as? CategoryFooterView else {
                return UICollectionReusableView()
            }
            headerCancellables.removeAll()
            // Footer 이벤트 연결
            footerView.publisher
                .sink { [weak self] _ in
                    self?.publisher.send()
                }
                .store(in: &headerCancellables) // CategoryCollectionView의 구독 관리

            return footerView
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 44, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let totalCellWidth: CGFloat = 44 * 6
        let totalPadding: CGFloat = screenWidth - 40 - totalCellWidth
        let interItemSpacing = floor(totalPadding / 5)
        return max(interItemSpacing, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) 
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
    
}

