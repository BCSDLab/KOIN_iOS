//
//  CenterFlowLayout.swift
//  koin
//
//  Created by 김나훈 on 12/16/24.
//

import UIKit

class CenterFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        var rows: [[UICollectionViewLayoutAttributes]] = []
        var currentRowY: CGFloat = -1
        
        for attribute in attributes where attribute.representedElementCategory == .cell {
            if currentRowY != attribute.frame.origin.y {
                currentRowY = attribute.frame.origin.y
                rows.append([attribute])
            } else {
                rows[rows.count - 1].append(attribute)
            }
        }
        
        for row in rows {
            guard let collectionView = collectionView else { continue }
            
            let totalCellWidth = row.reduce(0) { $0 + $1.frame.width }
            
            let delegateSpacing = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?
                .collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: 0) ?? 10

            let totalSpacingWidth = CGFloat(row.count - 1) * delegateSpacing
            let totalRowWidth = totalCellWidth + totalSpacingWidth
            let inset = collectionView.contentInset.left + collectionView.contentInset.right
            let contentWidth = collectionView.bounds.width - inset
            
            var currentX = (contentWidth - totalRowWidth) / 2
            
            for attribute in row {
                attribute.frame.origin.x = currentX
                currentX += attribute.frame.width + delegateSpacing
            }
        }
        
        return attributes
    }
}
