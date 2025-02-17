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
        case fetchChatDetail
        case blockUser
    }
    
    // MARK: - Output
    
    enum Output {
        case showChatList
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let chatRepository = DefaultChatRepository(service: DefaultChatService())
    private lazy var fetchChatDetailUseCase = DefaultFetchChatDetailUseCase(chatRepository: chatRepository)
    private let articleId: Int
    private let chatRoomId: Int
    let articleTitle: String
    private(set) var chatDetails: [ChatDetailDTO] = []
    
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
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ChatViewModel {
    
    private func blockUser() {
        
    }
    private func fetchChatDetail() {
        fetchChatDetailUseCase.execute(articleId: articleId, chatRoomId: chatRoomId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.chatDetails = response
            print(response)
        }.store(in: &subscriptions)

    }
    
}
