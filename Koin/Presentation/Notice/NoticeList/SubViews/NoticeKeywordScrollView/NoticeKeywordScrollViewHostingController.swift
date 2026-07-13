//
//  NoticeKeywordScrollViewHostingController.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI

final class NoticeKeywordScrollViewHostingController: UIHostingController<NoticeKeywordScrollView> {
    
    // MARK: - Properties
    private let store = NoticeKeywordStore()
        
    // MARK: - Initializer
    init(
        searchButtonTapped: @escaping ()->Void,
        manageButtonTapped: @escaping ()->Void,
        keywordAllButtonTapped: @escaping ()->Void,
        keywordButtonTapped: @escaping (NoticeKeywordDto)->Void,
        addButtonTapped: @escaping ()->Void
    ) {
        super.init(
            rootView: NoticeKeywordScrollView(
                store: store,
                searchButtonTapped: searchButtonTapped,
                manageButtonTapped: manageButtonTapped,
                keywordAllButtonTapped: keywordAllButtonTapped,
                keywordButtonTapped: keywordButtonTapped,
                addButtonTapped: addButtonTapped
            )
        )
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func updateKeyWordsList(keywordList: [NoticeKeywordDto], keywordIdx: Int) {
        store.noticeKeywordList = keywordList
        store.keywordIdx = keywordIdx
    }
}
