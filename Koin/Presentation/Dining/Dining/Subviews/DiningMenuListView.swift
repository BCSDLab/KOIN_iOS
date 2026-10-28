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
    let onImageTapped: (DiningItem)->Void
    let onScrolledDown: () -> Void
    
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
        onImageTapped: @escaping (DiningItem)->Void,
        onScrolledDown: @escaping () -> Void,
        shouldShowShareTooltip: Bool,
        onShareTapped: @escaping (DiningItem) -> Void,
        onCloseShareTooltipTapped: @escaping () -> Void,
        shouldShowReportButton: Bool,
        shouldShowReportTooltip: Bool,
        onReportTapped: @escaping (DiningItem?) -> Void,
        onCloseReportTooltipTapped: @escaping ()->Void,
    ) {
        self.list = list
        self.onImageTapped = onImageTapped
        self.onScrolledDown = onScrolledDown
        self.shouldShowShareTooltip = shouldShowShareTooltip
        self.onShareTapped = onShareTapped
        self.onCloseShareTooltipTapped = onCloseShareTooltipTapped
        self.shouldShowReportButton = shouldShowReportButton
        self.shouldShowReportTooltip = shouldShowReportTooltip
        self.onReportTapped = onReportTapped
        self.onCloseReportTooltipTapped = onCloseReportTooltipTapped
    }
    
    @State private var scrollLogDirection: ScrollLogDirection = .down
    @State private var dragStartOffsetY: CGFloat = 0
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center, spacing: 16) {
                ForEach(list.items, id: \.id) { item in
                    DiningMenuRowView(
                        item: item,
                        onImageTapped: onImageTapped,
                        onShareButtonTapped: onShareTapped,
                        shouldShowReportButton: shouldShowReportButton,
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
                    .isHidden(list.items.isEmpty)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .background{
            if list.items.isEmpty {
                DiningEmptyView()
            }
        }
        .onScrollPhaseChange { oldPhase, newPhase, context in
            makeLogEventIfNeeded(oldPhase, newPhase, context)
        }
        .overlayShareTooltip(
            shouldShowShareTooltip: shouldShowShareTooltip,
            onShareTooltipImageTapped: onShareTapped,
            onShareTooltipXButtonTapped: onCloseShareTooltipTapped,
            item: list.items.first
        )
        .overlayReportTooltip(
            shouldShowReportTooltip: shouldShowReportTooltip,
            onReportTooltipImageTapped: { onReportTapped(list.items.first) },
            onReportTooltipXButtonTapped: onCloseReportTooltipTapped
        )
    }
}

extension DiningMenuListView {
    private enum ScrollLogDirection {
        case down
        case up
        case checked
    }
    
    private func makeLogEventIfNeeded(
        _ oldPhase: ScrollPhase,
        _ newPhase: ScrollPhase,
        _ context: ScrollPhaseChangeContext
    ) {
        let offsetY = context.geometry.contentOffset.y
        if oldPhase != .interacting && newPhase == .interacting {
            dragStartOffsetY = offsetY
        }
        if oldPhase == .interacting && newPhase != .interacting {
            if offsetY < dragStartOffsetY {
                scrollLogDirection = .up
            } else if scrollLogDirection != .checked {
                scrollLogDirection = .down
            }
        }
        if (oldPhase == .interacting || oldPhase == .decelerating) && newPhase == .idle,
           scrollLogDirection == .down,
           offsetY > context.geometry.containerSize.height * 0.7 {
            onScrolledDown()
            scrollLogDirection = .checked
        }
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
        onReportTooltipImageTapped: @escaping ()->Void,
        onReportTooltipXButtonTapped: @escaping ()->Void
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
                        onImageTapped: onReportTooltipImageTapped
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
