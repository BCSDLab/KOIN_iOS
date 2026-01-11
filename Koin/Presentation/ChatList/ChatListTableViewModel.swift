//
//  ChatListTableViewModel.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine
import Foundation

final class ChatListTableViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case fetchChatRooms
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - Output
    
    enum Output {
        case showChatRoom
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var chatList: [ChatRoomItem] = [] {
        didSet {
            outputSubject.send(.showChatRoom)
        }
    }
    private let chatRepository = DefaultChatRepository(service: DefaultChatService())
    private lazy var fetchChatRoomUseCase = DefaultFetchChatRoomUseCase(chatRepository: chatRepository)
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
    
    // MARK: - Initialization
    
    init() {
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .fetchChatRooms:
                self?.fetchChatRooms()
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ChatListTableViewModel {

    private func fetchChatRooms() {
        fetchChatRoomUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.chatList = response
        }.store(in: &subscriptions)

    }
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
