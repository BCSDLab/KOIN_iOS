//
//  NoticeListView.swift
//  koin
//
//  Created by 홍기정 on 10/22/26.
//

import SwiftUI
import SwiftUIIntrospect

struct NoticeListView: ActionBindableView {
    enum Action {
        case showToastMessage(String)
        case navigateToNoticeData(noticeId: Int, boardId: Int)
        case navigateToSearch
        case navigateToManageKeyword
    }
    var sendAction: ((Action) -> Void) = { _ in }

    // MARK: - Properties
    @State private var viewModel: NoticeViewModel

    // MARK: - Initializer
    init(viewModel: NoticeViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            tabBarView

            tabView
        }
        .background(Color.appColor(.neutral0))
        .onFirstAppear {
            viewModel.execute(.onFirstAppear)
        }
        .onChange(of: viewModel.toastMessage) {
            if let toastMessage = viewModel.toastMessage {
                sendAction(.showToastMessage(toastMessage))
                viewModel.execute(.didShowToast)
            }
        }
        .onAppear {
            viewModel.execute(.onAppear)
        }
    }
}

extension NoticeListView {
    @ViewBuilder
    private var tabBarView: some View {
        NoticeTabBarRepresentable(
            selectedNoticeType: viewModel.selectedNoticeType,
            onTap: { type in
                viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.Notice.noticeTab, .click, type.displayName))
                viewModel.execute(.changeSelectedNoticeType(type))
            }
        )
        .frame(height: 50)
        .background(alignment: .bottom) {
            Color.appColor(.neutral400)
                .frame(height: 1)
        }
    }
}

extension NoticeListView {
    private var selectedNoticeType: Binding<NoticeListType> {
        Binding {
            viewModel.selectedNoticeType
        } set: { type in
            viewModel.execute(.changeSelectedNoticeType(type))
        }
    }

    @ViewBuilder
    private var tabView: some View {
        TabView(selection: selectedNoticeType) {
            ForEach(NoticeListType.allCases, id: \.self) { type in
                pageView(type: type)
                    .tag(type)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .introspect(
            .scrollView,
            on: .iOS(.v17, .v18, .v26, .v27)
        ) { scrollView in
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }

    @ViewBuilder
    private func pageView(type: NoticeListType) -> some View {
        if let pageViewModel = viewModel.pageViewModels[type] {
            NoticePageView(
                viewModel: pageViewModel,
                keywordList: viewModel.keywordList,
                isSelected: viewModel.selectedNoticeType == type,
                shouldShowTooltip: viewModel.shouldShowTooltip,
                onSearchTapped: {
                    viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.Notice.noticeSearch, .click, "검색"))
                    sendAction(.navigateToSearch)
                },
                onAddKeywordTapped: {
                    viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.Notice.addKeyword, .click, "키워드추가"))
                    sendAction(.navigateToManageKeyword)
                },
                onManageKeywordTapped: {
                    viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.Notice.manageKeyword, .click, "키워드관리"))
                    sendAction(.navigateToManageKeyword)
                },
                onArticleTapped: { noticeId, boardId in
                    sendAction(.navigateToNoticeData(noticeId: noticeId, boardId: boardId))
                },
                onCloseTooltipTapped: {
                    viewModel.execute(.didTapCloseTooltip)
                }
            )
        }
    }
}
