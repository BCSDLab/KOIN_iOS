//
//  CategoryView.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

@MainActor
struct CategoryView: ActionBindableView {
    
    // MARK: - Action
    enum Action {
        case showTimetable
        case showLostItem
        case showFacility
        case showDepartment
        case showDining
        case showShop
        case showBusTimetable
        case showBusRoute
        case showCallVan
        case showChatList
        case showLand
        case showBusiness
        case showRecruit
        
        case showLoginToast
    }

    // MARK: - Properties
    @State private var viewModel: CategoryViewModel
    var sendAction: ((Action) -> Void) = { _ in }

    // MARK: - Initializer
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Public
    func makeLogAnalyticsEvent(
        label: EventLabelType,
        value: Any
    ) {
        viewModel.execute(.logEvent(label, value))
    }

    // MARK: - Body
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    CategoryFeaturedButton(item: .recruit) {
                        didTapItem(.recruit)
                    }
                    CategoryFeaturedButton(item: .lostItem) {
                        didTapItem(.lostItem)
                    }
                }
                CategorySection(
                    title: "캠퍼스",
                    items: [
                        .facility,
                        .department,
                        .dining,
                        .shop,
                        .timetable
                    ],
                    action: { item in
                        didTapItem(item)
                    }
                )
                CategorySection(
                    title: "교통",
                    items: [
                        .busTimetable,
                        .busRoute,
                        .callVan
                    ],
                    action: { item in
                        didTapItem(item)
                    }
                )
                CategorySection(
                    title: "기타",
                    items: [
                        .chat,
                        .land,
                        .business
                    ],
                    action: { item in
                        didTapItem(item)
                    }
                )
            }
            .padding(.top, 23)
            .padding(.horizontal, 22)
            .padding(.bottom, 37)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .scrollIndicators(.hidden)
        .background(Color.appColor(.newBackground))
        .onAppear {
            viewModel.execute(.checkAuth)
        }
    }
}

private extension CategoryView {
    
    private func didTapItem(_ item: HomeCategoryItem) {
        if case item = .chat {
            guard viewModel.isLoggedIn else {
                sendAction(.showLoginToast)
                return
            }
        }
        
        let action = action(for: item)
        sendAction(action)
        
        if let loggingInfo = loggingInfo(for: action) {
            viewModel.execute(.logEvent(loggingInfo.label, loggingInfo.value))
        }
    }

    private func action(for item: HomeCategoryItem) -> Action {
        switch item {
        case .timetable:
            return .showTimetable
        case .lostItem:
            return .showLostItem
        case .facility:
            return .showFacility
        case .department:
            return .showDepartment
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
        case .chat:
            return .showChatList
        case .land:
            return .showLand
        case .business:
            return .showBusiness
        case .recruit:
            return .showRecruit
        }
    }

    private func loggingInfo(for action: Action) -> (label: EventLabelType, value: String)? {
        switch action {
        case .showRecruit:
            return (EventParameter.EventLabel.Home.DA1.teamRecruitMainCategoryCategoryNavigationTeamRecruitEntryClick, "팀원 모집")
        case .showLostItem:
            return (EventParameter.EventLabel.Home.DA2.boardMainCategoryCategoryNavigationLostItemEntryClick, "분실물")
        case .showFacility:
            return (EventParameter.EventLabel.Home.DA2.facilityMainCategoryCategoryNavigationFacilityEntryClick, "교내 시설물 정보")
        case .showDepartment:
            return (EventParameter.EventLabel.Home.DA2.departmentMainCategoryCategoryNavigationDepartmentEntryClick, "학교 부서 정보")
        case .showDining:
            return (EventParameter.EventLabel.Home.DA1.cafeteriaMainCategoryCategoryNavigationCafeteriaEntryClick, "식단")
        case .showShop:
            return (EventParameter.EventLabel.Home.DA1.shopMainCategoryCategoryNavigationShopEntryClick, "주변상점")
        case .showTimetable:
            return (EventParameter.EventLabel.Home.DA1.timetableMainCategoryCategoryNavigationTimetableEntryClick, "시간표")
        case .showBusTimetable:
            return (EventParameter.EventLabel.Home.DA1.busMainCategoryCategoryNavigationTimetableEntryClick, "버스 시간표")
        case .showBusRoute:
            return (EventParameter.EventLabel.Home.DA1.busMainCategoryCategoryNavigationSearchEntryClick, "교통편 조회하기")
        case .showCallVan:
            return (EventParameter.EventLabel.Home.DA2.callvanMainCategoryCategoryNavigationCallvanEntryClick, "콜벤팟 모집")
        case .showChatList:
            return (EventParameter.EventLabel.Home.DA2.chatMainCategoryCategoryNavigationChatEntryClick, "채팅")
        case .showLand:
            return (EventParameter.EventLabel.Home.DA1.realEstateMainCategoryCategoryNavigationRealEstateEntryClick, "복덕방")
        case .showBusiness:
            return (EventParameter.EventLabel.Home.DA1.ownerMainCategoryCategoryNavigationOwnerEntryClick, "코인 for Business")
        case .showLoginToast:
            return nil
        }
    }
}
