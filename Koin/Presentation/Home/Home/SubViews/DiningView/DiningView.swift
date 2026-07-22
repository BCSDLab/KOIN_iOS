//
//  DiningView.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

struct DiningView: View {
    private let diningItems: [HomeDiningItem]
    private let onTapAll: () -> Void
    private let onTapCorner: (HomeDiningItem) -> Void
    private let onTapMenu: (HomeDiningItem) -> Void
    @State private var selectedID: Int?

    init(
        diningItems: [HomeDiningItem],
        onTapAll: @escaping () -> Void,
        onTapCorner: @escaping (HomeDiningItem) -> Void,
        onTapMenu: @escaping (HomeDiningItem) -> Void
    ) {
        self.diningItems = diningItems
        self.onTapAll = onTapAll
        self.onTapCorner = onTapCorner
        self.onTapMenu = onTapMenu
    }

    var body: some View {
        VStack(spacing: 12) {
            DiningHeaderButton(onTapAll: onTapAll)

            DiningCarousel(
                diningItems: diningItems,
                selectedID: $selectedID,
                onTapCorner: onTapCorner,
                onTapMenu: onTapMenu
            )
            .padding(.bottom, 16)
            .emptyOverlay(diningItems.isEmpty) {
                EmptyDiningCard(action: onTapAll)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 16)
            }
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
        .onAppear {
            selectedID = selectedID ?? diningItems.first?.id
        }
        .onChange(of: diningItems.map(\.id)) { _, ids in
            guard !ids.contains(selectedID ?? -1) else { return }
            selectedID = ids.first
        }
    }
}
