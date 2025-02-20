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
        case fetchLostItem(Int)
        case deleteLostItem
        case checkAuth
        case checkLogin(CheckType)
        case createChatRoom
    }
    enum Output {
        case updateNoticeData(NoticeDataInfo)
        case updateLostItem(LostArticleDetailDTO)
        case updatePopularArticles([NoticeArticleDTO])
        case updateActivityIndictor(Bool, String?, URL?)
        case showToast(String)
        case showAuth(UserTypeResponse)
        case showLoginModal(CheckType)
        case navigateToScene(CheckType, Int)
        case navigateToChat(Int, Int, String)
        case popViewController
    }
    
    enum CheckType {
        case report
        case chat
    }
    
    private let fetchNoticeDataUseCase: FetchNoticeDataUseCase
    private let fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase
    private let downloadNoticeAttachmentUseCase: DownloadNoticeAttachmentsUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchLostItemUseCase = DefaultFetchLostItemUseCase(noticeListRepository: DefaultNoticeListRepository(service: DefaultNoticeService()))
    private let deleteLostItemUseCase = DefaultDeleteLostItemUseCase(noticeListRepository: DefaultNoticeListRepository(service: DefaultNoticeService()))
    private let checkAuthUseCase = DefaultCheckAuthUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private let createChatRoomUseCase = DefaultCreateChatRoomUseCase(chatRepository: DefaultChatRepository(service: DefaultChatService()))
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private(set) var noticeId: Int = 0
    private(set) var boardId: Int = 0
    private(set) var previousNoticeId: Int?
    private(set) var nextNoticeId: Int?
    
    init(fetchNoticeDataUseCase: FetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: DownloadNoticeAttachmentsUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, noticeId: Int, boardId: Int) {
        self.fetchNoticeDataUseCase = fetchNoticeDataUseCase
        self.fetchHotNoticeArticlesUseCase = fetchHotNoticeArticlesUseCase
        self.downloadNoticeAttachmentUseCase = downloadNoticeAttachmentUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.noticeId = noticeId
        self.boardId = boardId
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
            case let .fetchLostItem(id):
                self?.fetchLostItem(id: id)
            case .deleteLostItem:
                self?.deleteLostItem()
            case .checkAuth:
                self?.checkAuth()
            case let .checkLogin(checkType):
                self?.checkLogin(checkType: checkType)
            case .createChatRoom:
                self?.createChatRoom()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeDataViewModel {
    
    private func createChatRoom() {
        createChatRoomUseCase.execute(articleId: noticeId).sink(receiveCompletion: { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showToast(error.message))
            }
        }, receiveValue: { [weak self] response in
            self?.outputSubject.send(.navigateToChat(response.articleId, response.chatRoomId, response.articleTitle))
            WebSocketManager.shared.connect()
            WebSocketManager.shared.subscribeToChat(roomId: response.chatRoomId, articleId: response.articleId)
        }).store(in: &subscriptions)
    }
    
    private func checkLogin(checkType: CheckType) {
        checkLoginUseCase.execute().sink { [weak self] isLogined in
            if isLogined {
                self?.outputSubject.send(.navigateToScene(checkType, self?.noticeId ?? 0))
            } else {
                self?.outputSubject.send(.showLoginModal(checkType))
            }
        }.store(in: &subscriptions)
    }
    func checkAuth() {
        
        checkAuthUseCase.execute().sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] response in
            self?.outputSubject.send(.showAuth(response))
        }).store(in: &subscriptions)
        
    }
    
    private func deleteLostItem() {
        deleteLostItemUseCase.execute(id: noticeId).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("글이 삭제되었습니다."))
            self?.outputSubject.send(.popViewController)
        }).store(in: &subscriptions)
    }
    private func fetchLostItem(id: Int) {
        fetchLostItemUseCase.execute(id: id).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateLostItem(response))
        }).store(in: &subscriptions)
    }
    private func getNoticeData() {
        outputSubject.send(.updateActivityIndictor(true, nil, nil))
        let request = FetchNoticeDataRequest(noticeId: noticeId)
        fetchNoticeDataUseCase.execute(request: request).sink(receiveCompletion: { [weak self] completion in
            self?.outputSubject.send(.updateActivityIndictor(false, nil, nil))
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] noticeData in
            self?.outputSubject.send(.updateNoticeData(noticeData))
            self?.outputSubject.send(.updateActivityIndictor(false, nil, nil))
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
        outputSubject.send(.updateActivityIndictor(true, nil, nil))
        downloadNoticeAttachmentUseCase.execute(downloadUrl: downloadUrl, fileName: fileName).sink(receiveCompletion: { [weak self] completion in
            self?.outputSubject.send(.updateActivityIndictor(false, nil, nil))
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] downloadedPath in
            self?.outputSubject.send(.updateActivityIndictor(false, fileName, downloadedPath))
        }).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}

