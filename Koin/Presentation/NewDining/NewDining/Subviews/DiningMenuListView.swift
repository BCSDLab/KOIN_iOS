//
//  DiningMenuListView.swift
//  koin
//
//  Created by 홍기정 on 10/6/26.
//

import SwiftUI

struct DiningMenuListView: View {
    
    // MARK: - Property
    let list: DiningList
    let onImageTapped: (String)->Void
    
    let onShareTapped: (DiningItem) -> Void
    
    // MARK: - Initializer
    init(
        list: DiningList,
        onImageTapped: @escaping (String)->Void,
        onShareTapped: @escaping (DiningItem) -> Void,
    ) {
        self.list = list
        self.onImageTapped = onImageTapped
        self.onShareTapped = onShareTapped
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center, spacing: 16) {
                ForEach(list.items, id: \.id) { item in
                    DiningMenuRowView(
                        item: item,
                        onImageTapped: onImageTapped,
                        onShareButtonTapped: onShareTapped
                    )
                }
                
                DiningFooterView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
    }
}
