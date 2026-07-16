//
//  NoticeKeywordScrollView.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

// MARK: - HostingController Bridge
final class NoticeKeywordStore: ObservableObject {
    @Published var noticeKeywordList: [NoticeKeywordDto] = []
    @Published var selectedKeyword: NoticeKeywordDto?
    @Published var addButtonMinX: CGFloat = .zero
    
    @Published var showLoginToolTip: Bool = false
    @Published var showNotLoginToolTip: Bool = false
    
    func updateKeyWordsList(keywordList: [NoticeKeywordDto], selectedKeyword: NoticeKeywordDto?) {
        self.noticeKeywordList = keywordList
        self.selectedKeyword = selectedKeyword
    }
}

// MARK: - NamedCoordinateSpace
extension NamedCoordinateSpace {
    static let NoticeKeywordScrollView = "NoticeKeywordScrollView"
}

// MARK: - NoticeKeywordScrollView
struct NoticeKeywordScrollView: View {
    
    // MARK: - Properties
    @ObservedObject private var store: NoticeKeywordStore
    
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
                        store.selectedKeyword = nil
                    },
                    isSelected: store.selectedKeyword == nil
                )
                
                switch store.noticeKeywordList.isEmpty {
                case false:
                    ForEach(store.noticeKeywordList) { keyword in
                        NoticeKeywordButton(
                            action: {
                                keywordButtonTapped(keyword)
                                store.selectedKeyword = keyword
                            },
                            isSelected: store.selectedKeyword == keyword,
                            keyword: keyword.keyword
                        )
                    }
                case true:
                    NoticeKeywordAddButton(action: addButtonTapped)
                        .background {
                            GeometryReader { proxy in
                                let addButtonMinX = proxy.frame(in: .named(NamedCoordinateSpace.NoticeKeywordScrollView)).minX
                                Color.clear
                                    .frame(width: 0, height: 0)
                                    .preference(
                                        key: NoticeKeywordAddButtonOffsetXPreferenceKey.self,
                                        value: addButtonMinX
                                    )
                            }
                        }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
        }
        .scrollIndicators(.hidden)
        .onPreferenceChange(NoticeKeywordAddButtonOffsetXPreferenceKey.self) { addButtonMinX in
            store.addButtonMinX = addButtonMinX
        }
        .coordinateSpace(name: NamedCoordinateSpace.NoticeKeywordScrollView)
    }
    
    // MARK: - PreferenceKey
    struct NoticeKeywordAddButtonOffsetXPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = .zero
        
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    
}
