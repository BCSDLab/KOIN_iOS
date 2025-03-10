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
        case connectChat
    }
    
    // MARK: - Output
    
    enum Output {
        case showChatHistory([ChatMessage])
        case showToast(String, Bool)
        case addImageUrl(String)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let chatRepository = DefaultChatRepository(service: DefaultChatService())
    private lazy var fetchChatDetailUseCase = DefaultFetchChatDetailUseCase(chatRepository: chatRepository)
    private lazy var blockUserUserCase = DefaultBlockUserUseCase(chatRepository: chatRepository)
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
            case .connectChat:
                self?.connectChat()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ChatViewModel {
    
    private func connectChat() {
        WebSocketManager.shared.connect()
        WebSocketManager.shared.subscribeToChat(roomId: chatRoomId, articleId: articleId)
    }
    private func uploadFiles(files: [Data]) {
        uploadFileUseCase.execute(files: files).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.addImageUrl(response.fileUrls.first ?? ""))
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
        fetchChatDetailUseCase.execute(userId: UserDataManager.shared.id, articleId: articleId, chatRoomId: chatRoomId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showChatHistory(response))
        }.store(in: &subscriptions)
    }
    
}
