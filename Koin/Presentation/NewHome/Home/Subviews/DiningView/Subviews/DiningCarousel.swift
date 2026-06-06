//
//  DiningCarousel.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SwiftUI

struct DiningCarousel: View {
    let diningItems: [HomeDiningItem]
    @Binding var selectedID: Int?
    let onTapCorner: (HomeDiningItem) -> Void
    let onTapMenu: (HomeDiningItem) -> Void

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(diningItems, id: \.id) { item in
                            DiningMenuCard(item: item) {
                                onTapMenu(item)
                            }
                            .id(item.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .contentMargins(.horizontal, max((proxy.size.width - 312) / 2, 0), for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $selectedID)
            }
            .frame(height: 171)

            HStack(spacing: 6) {
                ForEach(diningItems, id: \.id) { item in
                    DiningIndicatorChip(
                        title: item.placeName,
                        isSelected: selectedID == item.id
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedID = item.id
                        }
                        onTapCorner(item)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
