//
//  CategoryView.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

@MainActor
struct CategoryView: View, ActionBindableView {
    enum Action {
        case showTimetable
        case showLostItem
        case showFacility
        case showDining
        case showShop
        case showBusTimetable
        case showBusRoute
        case showCallVan
        case showLand
        case showBusiness
    }

    @State private var viewModel: CategoryViewModel
    var sendAction: ((Action) -> Void) = { _ in }

    private let featuredItems: [NewHomeCategoryItem] = [
        .timetable,
        .lostItem
    ]

    private let sections: [CategorySectionContent] = [
        CategorySectionContent(
            title: "캠퍼스",
            items: [
                .facility,
                .dining,
                .shop
            ]
        ),
        CategorySectionContent(
            title: "교통",
            items: [
                .busTimetable,
                .busRoute,
                .callVan
            ]
        ),
        CategorySectionContent(
            title: "기타",
            items: [
                .land,
                .business
            ]
        )
    ]
    
    func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        viewModel.execute(.logEvent(label, category, value))
    }

    @MainActor
    init(viewModel: CategoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ForEach(featuredItems) { item in
                        CategoryFeaturedButton(item: item) {
                            didTapItem(item)
                        }
                    }
                }

                ForEach(sections) { section in
                    CategorySection(
                        title: section.title,
                        items: section.items,
                        action: { item in
                            didTapItem(item)
                        }
                    )
                }
            }
            .padding(.top, 23)
            .padding(.horizontal, 22)
            .padding(.bottom, 37)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .scrollIndicators(.hidden)
        .background(Color.appColor(.newBackground))
    }
}

private extension CategoryView {
    private func didTapItem(_ item: NewHomeCategoryItem) {
        let action = action(for: item)
        sendAction(action)
        
        let loggingInfo = loggingInfo(for: action)
        viewModel.execute(.logEvent(loggingInfo.label, .click, loggingInfo.value))
    }

    private func action(for item: NewHomeCategoryItem) -> Action {
        switch item {
        case .timetable:
            return .showTimetable
        case .lostItem:
            return .showLostItem
        case .facility:
            return .showFacility
        case .dining:
            return .showDining
        case .shop:
            return .showShop
        case .busTimetable:
            return .showBusTimetable
        case .busRoute:
            return .showBusRoute
        case .callVan:
            return .showCallVan
        case .land:
            return .showLand
        case .business:
            return .showBusiness
        }
    }

    private func loggingInfo(for action: Action) -> (label: EventParameter.EventLabel.Campus, value: String) {
        switch action {
        case .showTimetable:
            return (.categoryTimetable, "시간표")
        case .showLostItem:
            return (.categoryLostProperty, "분실물")
        case .showFacility:
            return (.categoryCampus, "교내 시설물 정보")
        case .showDining:
            return (.categoryCampus, "식단")
        case .showShop:
            return (.categoryCampus, "주변상점")
        case .showBusTimetable:
            return (.categoryTransportation, "버스 시간표")
        case .showBusRoute:
            return (.categoryTransportation, "교통편 조회하기")
        case .showCallVan:
            return (.categoryTransportation, "콜밴팟 모집")
        case .showLand:
            return (.categoryEtc, "복덕방")
        case .showBusiness:
            return (.categoryEtc, "코인 for Business")
        }
    }
}

private struct CategorySectionContent: Identifiable {
    var id: String { title }
    let title: String
    let items: [NewHomeCategoryItem]
}
