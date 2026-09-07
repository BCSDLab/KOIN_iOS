//
//  LeftAlignedLayout.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import SwiftUI

struct LeftAlignedLayout: Layout {
    var interitemSpacing: CGFloat
    var interlineSpacing: CGFloat
    
    init(
        interitemSpacing: CGFloat,
        interlineSpacing: CGFloat
    ) {
        self.interitemSpacing = interitemSpacing
        self.interlineSpacing = interlineSpacing
    }
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        layout(proposal: proposal, subviews: subviews).size
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = layout(proposal: proposal, subviews: subviews)
        
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + position.x,
                    y: bounds.minY + position.y
                ),
                proposal: .unspecified
            )
        }
    }
}

extension LeftAlignedLayout {
    private func layout(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> (
        size: CGSize,
        positions: [CGPoint]
    ) {
        let maxWidth = proposal.width ?? .infinity

        var positions: [CGPoint] = []

        var x: CGFloat = 0
        var y: CGFloat = 0

        var rowHeight: CGFloat = 0
        var contentWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            // 줄바꿈 판단
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += rowHeight + interlineSpacing
                rowHeight = 0
            }

            positions.append(
                CGPoint(
                    x: x,
                    y: y
                )
            )

            x += size.width + interitemSpacing
            rowHeight = max(rowHeight, size.height)
            contentWidth = max(contentWidth, x)
        }

        return (
            CGSize(
                width: contentWidth,
                height: y + rowHeight
            ),
            positions
        )
    }
}
