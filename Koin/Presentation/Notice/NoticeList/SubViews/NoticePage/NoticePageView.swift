//
//  NoticePageView.swift
//  koin
//
//  Created by 홍기정 on 10/22/26.
//

import SwiftUI

struct NoticePageView: View {

    // MARK: - Properties
    let viewModel: NoticePageViewModel
    let keywordList: [NoticeKeywordDto]
    let isSelected: Bool
    let shouldShowTooltip: Bool
    let onSearchTapped: () -> Void
    let onAddKeywordTapped: () -> Void
    let onManageKeywordTapped: () -> Void
    let onArticleTapped: (_ noticeId: Int, _ boardId: Int) -> Void
    let onCloseTooltipTapped: () -> Void

    @State private var addButtonMinX: CGFloat?
    @State private var contentOffsetY: CGFloat = 0

    // MARK: - Body
    var body: some View {
        NoticeListTableRepresentable(
            articles: viewModel.articles,
            pages: viewModel.pages,
            keywordList: keywordList,
            selectedKeyword: viewModel.keyword,
            isSelected: isSelected,
            onEvent: handle
        )
        .overlay(alignment: .topLeading) {
            if isSelected && shouldShowTooltip {
                tooltipView
            }
        }
    }
}

extension NoticePageView {
    private func handle(_ event: NoticeListTableRepresentable.Event) {
        switch event {
        case let .didTapKeyword(keyword):
            viewModel.execute(.selectKeyword(keyword.keyword))
        case .didTapAllKeyword:
            viewModel.execute(.didTapAllKeyword)
        case let .didTapPage(page):
            viewModel.execute(.changePage(page))
        case .didScroll:
            viewModel.execute(.logScroll)
        case .didTapSearch:
            onSearchTapped()
        case .didTapAddKeyword:
            onAddKeywordTapped()
        case .didTapManageKeyword:
            onManageKeywordTapped()
        case let .didTapArticle(noticeId, boardId):
            onArticleTapped(noticeId, boardId)
        case let .didChangeAddButtonMinX(addButtonMinX):
            self.addButtonMinX = addButtonMinX
        case let .didChangeContentOffsetY(contentOffsetY):
            self.contentOffsetY = contentOffsetY
        }
    }
}

extension NoticePageView {
    @ViewBuilder
    private var tooltipView: some View {
        let isLoggedIn = UserDataManager.shared.isLoggedIn
        let width: CGFloat = isLoggedIn ? 246 : 223
        let translationX = addButtonMinX.map { $0 + 13 - width / 2 + 22 } ?? 0

        CancelableImage(
            imageAsset: isLoggedIn ? .noticeLoginToolTip : .noticeNotLoginToolTip,
            xButtonLayout: .init(
                topInset: 8,
                bottomInset: 6
            ),
            onXButtonTapped: onCloseTooltipTapped
        )
        .frame(width: width, height: 44)
        .padding(.top, 44)
        .offset(x: -24 + translationX, y: -contentOffsetY)
    }
}
