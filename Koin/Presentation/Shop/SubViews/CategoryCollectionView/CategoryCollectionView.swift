//
//  CategoryCollectionView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit

final class CategoryCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var shopCategories: [ShopCategory] = []
    let cellTapPublisher = PassthroughSubject<Int, Never>()
    let selectedCategoryPublisher = CurrentValueSubject<Int, Never>(0)
    private var selectedId = 0
    
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
                let categoryIndex = indexPath.section == 0 ? indexPath.row : indexPath.row + 6
                let category = shopCategories[categoryIndex]
                let isSelected = category.id == id
                cell.configure(info: category, isSelected)
            }
        }
        selectedCategoryPublisher.send(selectedId)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // 상단 섹션과 하단 섹션 2개로 나눔
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 6 : 5 // 첫 번째 섹션에는 6개, 두 번째 섹션에는 5개 아이템
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let categoryIndex = indexPath.section == 0 ? indexPath.row : indexPath.row + 6
        
        // 범위 검사를 통해 안전하게 데이터 할당
        guard categoryIndex < shopCategories.count else {
            return cell
        }
        
        let category = shopCategories[categoryIndex]
        let isSelected = category.id == selectedId
        cell.configure(info: category, isSelected)
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryIndex = indexPath.section == 0 ? indexPath.row : indexPath.row + 6
        let category = shopCategories[categoryIndex]
        selectedId = category.id
        cellTapPublisher.send(selectedId)
        reloadData()
    }
}

// MARK: - CategoryCollectionView Layout
extension CategoryCollectionView {
    
    
}

extension CategoryCollectionView: UICollectionViewDelegateFlowLayout {
    
    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50) // 셀 크기 50x50
    }
    
    // 셀 간 좌우 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5 // 셀 간 간격 20
    }
    
    // 줄 간격 설정 (수평 레이아웃에서는 적용되지 않음)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // 줄 간격 10
    }
    
    // 섹션 내부 패딩 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 0, bottom: 10, right: 0) // 섹션 간격 설정
    }
}

