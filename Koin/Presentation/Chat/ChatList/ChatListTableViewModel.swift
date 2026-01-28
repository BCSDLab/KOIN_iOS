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
        case viewWillDisappear
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - Output
    
    enum Output {
        case showChatRoom
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var pollingSubscriptions: AnyCancellable?
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
            case .viewWillDisappear:
                guard let self else { return }
                pollingSubscriptions?.cancel()
                pollingSubscriptions = nil
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ChatListTableViewModel {

    private func fetchChatRooms() {
        pollingSubscriptions?.cancel()
        pollingSubscriptions = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .flatMap { [weak self] _ -> AnyPublisher<[ChatRoomItem], Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return fetchChatRoomUseCase.execute()
                    .catch { error -> AnyPublisher<[ChatRoomItem], Never> in
                        Log.make().error("\(error)")
                        return Empty().eraseToAnyPublisher()
                    }.eraseToAnyPublisher()
            }
            .sink { [weak self] response in
                self?.chatList = response
            }
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
