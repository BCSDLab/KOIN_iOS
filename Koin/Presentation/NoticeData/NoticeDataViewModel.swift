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
        case downloadFile(String, String)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateNoticeData(NoticeDataInfo)
        case updatePopularArticles([NoticeArticleDTO])
        case updateActivityIndictor(Bool, String?)
    }
    
    private let fetchNoticeDataUseCase: FetchNoticeDataUseCase
    private let fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase
    private let downloadNoticeAttachmentUseCase: DownloadNoticeAttachmentsUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var noticeId: Int = 0
    var previousNoticeId: Int?
    var nextNoticeId: Int?
    
    init(fetchNoticeDataUseCase: FetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: DownloadNoticeAttachmentsUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, noticeId: Int) {
        self.fetchNoticeDataUseCase = fetchNoticeDataUseCase
        self.fetchHotNoticeArticlesUseCase = fetchHotNoticeArticlesUseCase
        self.downloadNoticeAttachmentUseCase = downloadNoticeAttachmentUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.noticeId = noticeId
    }

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getNoticeData:
                self?.getNoticeData()
            case .getPopularNotices:
                self?.getPopularArticle()
            case let .downloadFile(downloadUrl, fileName):
                self?.downloadFile(downloadUrl: downloadUrl, fileName: fileName)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeDataViewModel {
    private func getNoticeData() {
        outputSubject.send(.updateActivityIndictor(true, nil))
        let request = FetchNoticeDataRequest(noticeId: noticeId)
        fetchNoticeDataUseCase.execute(request: request).sink(receiveCompletion: { [weak self] completion in
            self?.outputSubject.send(.updateActivityIndictor(false, nil))
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] noticeData in
            self?.outputSubject.send(.updateNoticeData(noticeData))
            self?.outputSubject.send(.updateActivityIndictor(false, nil))
        }).store(in: &subscriptions)
    }
    
    private func getPopularArticle() {
        fetchHotNoticeArticlesUseCase.execute(noticeId: noticeId).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] notices in
            self?.outputSubject.send(.updatePopularArticles(notices))
        }).store(in: &subscriptions)
    }
    
    private func downloadFile(downloadUrl: String, fileName: String) {
        outputSubject.send(.updateActivityIndictor(true, nil))
        downloadNoticeAttachmentUseCase.execute(downloadUrl: downloadUrl, fileName: fileName).sink(receiveCompletion: { [weak self] completion in
            self?.outputSubject.send(.updateActivityIndictor(false, fileName))
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] in
            self?.outputSubject.send(.updateActivityIndictor(false, fileName))
        }).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

