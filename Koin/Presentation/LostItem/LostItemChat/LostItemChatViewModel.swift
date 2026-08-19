//
//  LostItemChatViewModel.swift
//  koin
//
//  Created by 김나훈 on 2/16/25.
//

import Combine
import Foundation

final class LostItemChatViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case viewDidLoad
        case uploadFile([Data])
        case fetchChatDetail
        case blockUser
        case viewWillDisappear
        case sendMessage(String, Bool)
    }
    
    // MARK: - Output
    
    enum Output {
        case updateTitle(String)
        case showChatHistory([LostItemChatMessage])
        case showToast(String, Bool)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var pollingSubscriptions: AnyCancellable?
    private let chatRepository = DefaultLostItemRepository(service: DefaultLostItemService())
    private lazy var fetchChatDetailUseCase = DefaultLostItemFetchChatDetailUseCase(chatRepository: chatRepository)
    private lazy var blockUserUserCase = DefaultLostItemBlockUserUseCase(chatRepository: chatRepository)
    private lazy var postChatDetailUseCase = DefaultLostItemPostChatDetailUseCase(chatRepository: chatRepository)
    private let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private lazy var uploadFileUseCase = DefaultUploadFileUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))
    private lazy var fetchChatRoomUseCase = DefaultLostItemFetchChatRoomUseCase(chatRepository: chatRepository)
    let articleId: Int
    let chatRoomId: Int
    private var articleTitle: String?
    
    
    // MARK: - Initialization
    init(articleId: Int, chatRoomId: Int, articleTitle: String?) {
        self.articleId = articleId
        self.chatRoomId = chatRoomId
        self.articleTitle = articleTitle
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.fetchArticleTitle()
            case .fetchChatDetail:
                self?.fetchChatDetail()
            case .blockUser:
                self?.blockUser()
            case .uploadFile(let files):
                self?.uploadFiles(files: files)
            case .viewWillDisappear:
                guard let self else { return }
                pollingSubscriptions?.cancel()
                pollingSubscriptions = nil
            case .sendMessage(let message, let isImage):
                self?.sendMessage(message: message, isImage: isImage)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension LostItemChatViewModel {
    
    private func uploadFiles(files: [Data]) {
        uploadFileUseCase.execute(files: files, domain: .lostItem).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            if let imageUrl = response.fileUrls.first {
                self?.sendMessage(message: imageUrl, isImage: true)
            }
        }.store(in: &subscriptions)
        
    }

    private func blockUser() {
        blockUserUserCase.execute(articleId: articleId, chatRoomId: chatRoomId).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("사용자가 차단되었습니다.", true))
        }.store(in: &subscriptions)
    }
    
    private func fetchChatDetail() {
        pollingSubscriptions?.cancel()
        pollingSubscriptions = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .flatMap { [weak self] _ -> AnyPublisher<[LostItemChatMessage], Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return fetchChatDetailUseCase.execute(userId: UserDataManager.shared.id, articleId: articleId, chatRoomId: chatRoomId)
                    .catch { error -> AnyPublisher<[LostItemChatMessage], Never> in
                        return Empty().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] response in
                print(response)
                self?.outputSubject.send(.showChatHistory(response))
            }
    }
    
    private func sendMessage(message: String, isImage: Bool) {
        postChatDetailUseCase.execute(articleId: articleId, chatRoomId: chatRoomId, message: message, isImage: isImage).sink(
            receiveCompletion: { [weak self] completion in
                if case .finished = completion {
                    self?.fetchChatDetail()
                }
            },
            receiveValue: { _ in }
        ).store(in: &subscriptions)
    }
    
    private func fetchArticleTitle() {
        if let articleTitle {
            outputSubject.send(.updateTitle(articleTitle))
            return
        }        
        fetchChatRoomUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] chatRoomItem in
                guard let self else { return }
                if let chatRoomItem = chatRoomItem.first(where: { $0.chatRoomId == self.chatRoomId }) {
                    self.articleTitle = chatRoomItem.articleTitle
                    outputSubject.send(.updateTitle(chatRoomItem.articleTitle))
                }
            }
        ).store(in: &subscriptions)
    }
    
}
