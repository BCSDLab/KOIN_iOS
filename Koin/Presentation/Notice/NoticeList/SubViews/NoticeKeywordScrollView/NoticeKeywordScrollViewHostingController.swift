//
//  NoticeKeywordScrollViewHostingController.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import SwiftUI
import Combine

final class NoticeKeywordScrollViewHostingController: UIHostingController<NoticeKeywordScrollView> {
    
    // MARK: - Properties
    let addButtonMinXPublisher = PassthroughSubject<CGFloat, Never>()
    private let store = NoticeKeywordStore()
    private var subscriptions: Set<AnyCancellable> = []
        
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
        
        bind()
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func updateKeyWordsList(keywordList: [NoticeKeywordDto], selectedKeyword: NoticeKeywordDto?) {
        store.noticeKeywordList = keywordList
        store.selectedKeyword = selectedKeyword
    }
    
    // MARK: - Bind
    private func bind() {
        store.$addButtonMinX
            .sink { [weak self] addButtonMinX in
                self?.addButtonMinXPublisher.send(addButtonMinX)
            }
            .store(in: &subscriptions)
    }
}
