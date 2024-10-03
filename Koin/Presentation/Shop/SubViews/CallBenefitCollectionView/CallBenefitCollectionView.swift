//
//  CallBenefitCollectionView.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Combine
import UIKit

final class CallBenefitCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var cancellables = Set<AnyCancellable>()
    let filterPublisher = PassthroughSubject<Int, Never>()
    private var benefits: [Benefit] = []
    
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
        register(CallBenefitCollectionViewCell.self, forCellWithReuseIdentifier: ShopInfoCollectionViewCell.identifier)
        register(CallBenefitFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CallBenefitFooterView.identifier)
        dataSource = self
        delegate = self
    }
    
    func updateBenefits(benefits: ShopBenefitsDTO) {
        self.benefits = benefits.benefits ?? []
        if let firstBenefit = benefits.benefits?.first {
            if let footerView = self.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as? CallBenefitFooterView {
                footerView.updateLabel(with: firstBenefit.detail)
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let firstCell = self.cellForItem(at: IndexPath(item: 0, section: 0)) as? CallBenefitCollectionViewCell,
               let firstBenefit = self.benefits.first {
                firstCell.updateCell(selected: true, benefit: firstBenefit)
            }
        }
        self.reloadData() 
    }
}

extension CallBenefitCollectionView {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 셀의 너비는 컬렉션 뷰의 절반, 간격을 고려하여 정확하게 맞춥니다
        let totalWidth = collectionView.bounds.width
        let numberOfItemsPerRow: CGFloat = 2
        let spacingBetweenCells: CGFloat = 15
        
        let width = (totalWidth - (spacingBetweenCells * (numberOfItemsPerRow + 1))) / numberOfItemsPerRow
        return CGSize(width: width, height: 50) // 높이는 50 고정
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15 // 세로 간격 15 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15 // 좌우 간격 15 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) // 좌우 여백을 15로 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CallBenefitFooterView.identifier, for: indexPath) as? CallBenefitFooterView else {
                return UICollectionReusableView()
            }
            
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return benefits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CallBenefitCollectionViewCell.identifier, for: indexPath) as? CallBenefitCollectionViewCell else {
            return UICollectionViewCell()
        }
        let cellItem = benefits[indexPath.row]
        cell.updateCell(selected: false, benefit: cellItem)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBenefit = benefits[indexPath.row]
        
        // 모든 셀을 순회하며 이미지 업데이트
        for (index, _) in benefits.enumerated() {
            if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? CallBenefitCollectionViewCell {
                if index == indexPath.row {
                    cell.updateCell(selected: true, benefit: benefits[index])
                } else {
                    cell.updateCell(selected: false, benefit: benefits[index])
                }
            }
        }
        
        // Footer 업데이트
        filterPublisher.send(selectedBenefit.id)
        if let footerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as? CallBenefitFooterView {
            footerView.updateLabel(with: selectedBenefit.detail)
        }
    }
}
