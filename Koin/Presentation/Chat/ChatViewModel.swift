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
    private(set) var userId = 0
    
    
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
                self?.fetchUserData()
            case .blockUser:
                self?.blockUser()
            case .uploadFile(let files):
                self?.uploadFiles(files: files)
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
            self?.outputSubject.send(.addImageUrl(response.fileUrls.first ?? ""))
        }.store(in: &subscriptions)
        
    }
    private func fetchUserData() {
        fetchUserDataUseCase.execute().sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.fetchChatDetail(userId: response.id)
            WebSocketManager.shared.setUserId(id: response.id)
            self?.userId = response.id
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
    private func fetchChatDetail(userId: Int) {
        fetchChatDetailUseCase.execute(userId: userId, articleId: articleId, chatRoomId: chatRoomId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showChatHistory(response))
        }.store(in: &subscriptions)
    }
    
}
