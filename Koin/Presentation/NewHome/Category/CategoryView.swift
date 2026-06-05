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

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                
                HStack(spacing: 12) {
                    ForEach(featuredItems) { item in
                        CategoryFeaturedButton(item: item) {
                            sendAction(Action(item))
                        }
                    }
                }

                ForEach(sections) { section in
                    CategorySection(
                        title: section.title,
                        items: section.items,
                        action: { item in
                            sendAction(Action(item))
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

private extension CategoryView.Action {
    init(_ item: NewHomeCategoryItem) {
        switch item {
        case .timetable:
            self = .showTimetable
        case .lostItem:
            self = .showLostItem
        case .facility:
            self = .showFacility
        case .dining:
            self = .showDining
        case .shop:
            self = .showShop
        case .busTimetable:
            self = .showBusTimetable
        case .busRoute:
            self = .showBusRoute
        case .callVan:
            self = .showCallVan
        case .land:
            self = .showLand
        case .business:
            self = .showBusiness
        }
    }
}

private struct CategorySectionContent: Identifiable {
    var id: String { title }
    let title: String
    let items: [NewHomeCategoryItem]
}
