//
//  DiningTypeView.swift
//  koin
//
//  Created by 홍기정 on 10/6/26.
//

import SwiftUI

struct DiningTypeView: View {
    
    // MARK: - Properties
    private let duration: CGFloat = 0.2
    private let types: [DiningType]
    private let selectedType: DiningType
    private let action: (DiningType)->Void
    
    // MARK: - Initializer
    init(
        types: [DiningType],
        selectedType: DiningType,
        action: @escaping (DiningType)->Void
    ) {
        self.types = types
        self.selectedType = selectedType
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            ForEach(types, id: \.id) { type in
                typeView(type)
            }
        }
        .background(alignment: .bottom) {
            Color.appColor(.neutral400)
                .frame(height: 1)
                .frame(maxWidth: .infinity, alignment: .bottom)
        }
        .overlay(alignment: .bottomLeading) {
            GeometryReader { proxy in
                Color.appColor(.new600)
                    .frame(height: 2)
                    .frame(maxWidth: proxy.size.width / 3, alignment: .bottom)
                    .offset(CGSize(
                        width: CGFloat(selectedType.index) * proxy.size.width / 3,
                        height: 50 - 2
                    ))
                    .animation(.spring(duration: duration), value: selectedType.index)
            }
        }
    }
}

extension DiningTypeView {
    private func typeView(_ type: DiningType) -> some View {
        Button {
            action(type)
        } label: {
            Text(type.name)
                .font(.appFont(type == selectedType ? .pretendardBold : .pretendardRegular, size: 16))
                .foregroundStyle(Color.appColor(type == selectedType ? .new500 : .neutral500))
                .frame(height: 50)
                .frame(maxWidth: .infinity, alignment: .center)
                .animation(.easeInOut(duration: duration), value: type == selectedType)
        }
        .buttonStyle(.plain)
    }
}
