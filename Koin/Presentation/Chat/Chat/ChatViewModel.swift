//
//  ChatViewModel.swift
//  koin
//
//  Created by 김나훈 on 2/16/25.
//

import Combine
import Foundation

final class ChatViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case uploadFile([Data])
        case fetchChatDetail
        case blockUser
        case viewWillDisappear
        case sendMessage(String, Bool)
    }
    
    // MARK: - Output
    
    enum Output {
        case showChatHistory([ChatMessage])
        case showToast(String, Bool)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var pollingSubscriptions: AnyCancellable?
    private let chatRepository = DefaultChatRepository(service: DefaultChatService())
    private lazy var fetchChatDetailUseCase = DefaultFetchChatDetailUseCase(chatRepository: chatRepository)
    private lazy var blockUserUserCase = DefaultBlockUserUseCase(chatRepository: chatRepository)
    private lazy var postChatDetailUseCase = DefaultPostChatDetailUseCase(chatRepository: chatRepository)
    private let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private lazy var uploadFileUseCase: UploadFileUseCase = DefaultUploadFileUseCase(shopRepository: DefaultShopRepository(service: DefaultShopService()))
    let articleId: Int
    let chatRoomId: Int
    let articleTitle: String
    
    
    // MARK: - Initialization
    
    init(articleId: Int, chatRoomId: Int, articleTitle: String) {
        self.articleId = articleId
        self.chatRoomId = chatRoomId
        self.articleTitle = articleTitle
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
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

extension ChatViewModel {
    
    private func uploadFiles(files: [Data]) {
        uploadFileUseCase.execute(files: files).sink { [weak self] completion in
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
        pollingSubscriptions = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .flatMap { [weak self] _ -> AnyPublisher<[ChatMessage], Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return fetchChatDetailUseCase.execute(userId: UserDataManager.shared.id, articleId: articleId, chatRoomId: chatRoomId)
                    .catch { error -> AnyPublisher<[ChatMessage], Never> in
                        Log.make().error("\(error)")
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
                switch completion {
                case .failure(let error):
                    Log.make().error("\(error)")
                case .finished:
                    self?.fetchChatDetail()
                }
            },
            receiveValue: { _ in }
        ).store(in: &subscriptions)
    }
    
}
