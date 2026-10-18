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
    
    let shouldShowShareTooltip: Bool
    let onShareTapped: (DiningItem) -> Void
    let onCloseShareTooltipTapped: () -> Void
    
    // MARK: - Initializer
    init(
        list: DiningList,
        onImageTapped: @escaping (String)->Void,
        shouldShowShareTooltip: Bool,
        onShareTapped: @escaping (DiningItem) -> Void,
        onCloseShareTooltipTapped: @escaping () -> Void,
    ) {
        self.list = list
        self.onImageTapped = onImageTapped
        self.shouldShowShareTooltip = shouldShowShareTooltip
        self.onShareTapped = onShareTapped
        self.onCloseShareTooltipTapped = onCloseShareTooltipTapped
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
                    .anchorPreference(
                        key: FirstRowViewPreferenceKey.self,
                        value: .bounds
                    ) { anchor in
                        item.id == list.items.first?.id ? anchor : nil
                    }
                }
                
                DiningFooterView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .overlayShareTooltip(
            shouldShowShareTooltip: shouldShowShareTooltip,
            onShareTooltipImageTapped: onShareTapped,
            onShareTooltipXButtonTapped: onCloseShareTooltipTapped,
            item: list.items.first
        )
    }
}

// MARK: - Modifier
private extension View {
    func overlayShareTooltip(
        shouldShowShareTooltip: Bool,
        onShareTooltipImageTapped: @escaping (DiningItem)->Void,
        onShareTooltipXButtonTapped: @escaping ()->Void,
        item: DiningItem?
    ) -> some View {
        overlayPreferenceValue(FirstRowViewPreferenceKey.self) { anchor in
            GeometryReader { proxy in
                if shouldShowShareTooltip, let anchor {
                    let rowFrame = proxy[anchor]
                    CancelableImage(
                        imageAsset: .diningShare,
                        xButtonLayout: .init(
                            topInset: 16,
                            bottomInset: 26
                        ),
                        onXButtonTapped: onShareTooltipXButtonTapped,
                        onImageTapped: {
                            if let item {
                                onShareTooltipImageTapped(item)
                            }
                        }
                    )
                    .position(
                        x: rowFrame.midX,
                        y: rowFrame.maxY - 6 + 44 / 2
                    )
                    .animateTooltip(
                        offsetY: 10,
                        duration: 0.7
                    )
                }
            }
        }
    }
}

// MARK: - PreferenceKey
private struct FirstRowViewPreferenceKey: PreferenceKey {
    typealias Value = Anchor<CGRect>?
    
    static let defaultValue: Self.Value? = nil
    
    static func reduce(
        value: inout Self.Value,
        nextValue: () -> Self.Value
    ) {
        value = value ?? nextValue()
    }
}

// MARK: - Modifier
private extension View {
    func animateTooltip(offsetY: CGFloat, duration: CGFloat) -> some View{
        keyframeAnimator(initialValue: 0.0, repeating: true) { content, offsetY in
            content.offset(y: offsetY)
        } keyframes: { _ in
            LinearKeyframe(10, duration: duration, timingCurve: .easeInOut)
            LinearKeyframe(0, duration: duration, timingCurve: .easeInOut)
        }
    }
}
