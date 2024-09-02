//
//  NoticeDataViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import Foundation

final class NoticeDataViewModel: ViewModelProtocol {
    
    enum Input {
        case getNoticeData
        case getPopularNotices
    }
    enum Output {
        case updateNoticeData(NoticeDataInfo)
        case updatePopularArticles([NoticeArticleDTO])
    }
    
    private let fetchNoticeDataUseCase: FetchNoticeDataUseCase
    private let fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var noticeId: Int = 0
    var previousNoticeId: Int?
    var nextNoticeId: Int?
    
    init(fetchNoticeDataUseCase: FetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase, noticeId: Int) {
        self.fetchNoticeDataUseCase = fetchNoticeDataUseCase
        self.fetchHotNoticeArticlesUseCase = fetchHotNoticeArticlesUseCase
        self.noticeId = noticeId
    }

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getNoticeData:
                self?.getNoticeData()
            case .getPopularNotices:
                self?.getPopularArticle()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeDataViewModel {
    func getNoticeData() {
        let request = FetchNoticeDataRequest(noticeId: noticeId)
        fetchNoticeDataUseCase.fetchNoticeData(request: request).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] noticeData in
            self?.outputSubject.send(.updateNoticeData(noticeData))
        }).store(in: &subscriptions)
    }
    
    func getPopularArticle() {
        fetchHotNoticeArticlesUseCase.execute(noticeId: noticeId).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] notices in
            self?.outputSubject.send(.updatePopularArticles(notices))
        }).store(in: &subscriptions)
    }
}

