//
//  NoticeKeywordScrollView.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

final class NoticeKeywordStore: ObservableObject {
    @Published var noticeKeywordList: [NoticeKeywordDto] = []
    @Published var keywordIdx: Int = 0
    
    func updateKeyWordsList(keywordList: [NoticeKeywordDto], keywordIdx: Int) {
        self.noticeKeywordList = keywordList
        self.keywordIdx = keywordIdx
    }
}

struct NoticeKeywordScrollView: View {
    
    // MARK: - Properties
    @ObservedObject private var store: NoticeKeywordStore
    @State private var selectedKeyword: NoticeKeywordDto? = nil
    
    private let searchButtonTapped: ()->Void
    private let manageButtonTapped: ()->Void
    private let keywordAllButtonTapped: ()->Void
    private let keywordButtonTapped: (NoticeKeywordDto)->Void
    private let addButtonTapped: ()->Void

    // MARK: - Initializer
    init(
        store: NoticeKeywordStore,
        searchButtonTapped: @escaping ()->Void,
        manageButtonTapped: @escaping ()->Void,
        keywordAllButtonTapped: @escaping ()->Void,
        keywordButtonTapped: @escaping (NoticeKeywordDto)->Void,
        addButtonTapped: @escaping ()->Void
    ) {
        self.store = store
        self.searchButtonTapped = searchButtonTapped
        self.manageButtonTapped = manageButtonTapped
        self.keywordAllButtonTapped = keywordAllButtonTapped
        self.keywordButtonTapped = keywordButtonTapped
        self.addButtonTapped = addButtonTapped
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: 8) {
                NoticeKeywordSearchButton(action: searchButtonTapped)
                
                NoticeKeywordManageButton(action: manageButtonTapped)
                
                NoticeKeywordAllButton(
                    action: {
                        keywordAllButtonTapped()
                        selectedKeyword = nil
                    },
                    isSelected: selectedKeyword == nil
                )
                
                switch store.noticeKeywordList.isEmpty {
                case false:
                    ForEach(store.noticeKeywordList) { keyword in
                        NoticeKeywordButton(
                            action: {
                                keywordButtonTapped(keyword)
                                selectedKeyword = keyword
                            },
                            isSelected: selectedKeyword == keyword,
                            keyword: keyword.keyword
                        )
                    }
                case true:
                    NoticeKeywordAddButton(action: addButtonTapped)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
        }
        .scrollIndicators(.hidden)
    }
}
