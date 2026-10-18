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
    let currentItems: [DiningItem]
    let onImageTapped: (String)->Void
    
    let shouldShowShareTooltip: Bool
    let onShareTapped: (DiningItem) -> Void
    let onCloseShareTooltipTapped: () -> Void
    
    let shouldShowReportButton: Bool
    let shouldShowReportTooltip: Bool
    let onReportTapped: (DiningItem?) -> Void
    let onCloseReportTooltipTapped: ()->Void
    
    // MARK: - Initializer
    init(
        list: DiningList,
        currentItems: [DiningItem],
        onImageTapped: @escaping (String)->Void,
        shouldShowShareTooltip: Bool,
        onShareTapped: @escaping (DiningItem) -> Void,
        onCloseShareTooltipTapped: @escaping () -> Void,
        shouldShowReportButton: Bool,
        shouldShowReportTooltip: Bool,
        onReportTapped: @escaping (DiningItem?) -> Void,
        onCloseReportTooltipTapped: @escaping ()->Void,
    ) {
        self.list = list
        self.currentItems = currentItems
        self.onImageTapped = onImageTapped
        self.shouldShowShareTooltip = shouldShowShareTooltip
        self.onShareTapped = onShareTapped
        self.onCloseShareTooltipTapped = onCloseShareTooltipTapped
        self.shouldShowReportButton = shouldShowReportButton
        self.shouldShowReportTooltip = shouldShowReportTooltip
        self.onReportTapped = onReportTapped
        self.onCloseReportTooltipTapped = onCloseReportTooltipTapped
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center, spacing: 16) {
                ForEach(list.items, id: \.id) { item in
                    DiningMenuRowView(
                        item: item,
                        onImageTapped: onImageTapped,
                        onShareButtonTapped: onShareTapped,
                        shouldShowReportButton: (shouldShowReportButton && currentItems.contains(item)),
                        onReportButtonTapped: onReportTapped
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
        .overlayReportTooltip(
            shouldShowReportTooltip: shouldShowReportTooltip,
            onReportTooltipImageTapped: onReportTapped,
            onReportTooltipXButtonTapped: onCloseReportTooltipTapped,
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
    
    func overlayReportTooltip(
        shouldShowReportTooltip: Bool,
        onReportTooltipImageTapped: @escaping (DiningItem?)->Void,
        onReportTooltipXButtonTapped: @escaping ()->Void,
        item: DiningItem?
    ) -> some View {
        overlayPreferenceValue(ReportButtonPreferenceKey.self) { anchor in
            GeometryReader { proxy in
                if shouldShowReportTooltip, let anchor {
                    let rowFrame = proxy[anchor]
                    CancelableImage(
                        imageAsset: DiningReportAbTest.card.imageAsset,
                        xButtonLayout: .init(
                            topInset: 16,
                            bottomInset: 26
                        ),
                        onXButtonTapped: onReportTooltipXButtonTapped,
                        onImageTapped: {
                            onReportTooltipImageTapped(item)
                        }
                    )
                    .position(
                        x: rowFrame.midX + 66,
                        y: rowFrame.maxY + 35
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
