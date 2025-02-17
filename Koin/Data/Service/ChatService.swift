//
//  ChatService.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Alamofire
import Combine

protocol ChatService {
    func fetchChatRoom() -> AnyPublisher<[ChatRoomDTO], ErrorResponse>
}

final class DefaultChatService: ChatService {
    
    private let networkService = NetworkService()
    
    func fetchChatRoom() -> AnyPublisher<[ChatRoomDTO], ErrorResponse> {
        return networkService.requestWithResponse(api: ChatAPI.fetchChatRoom)
            .catch { [weak self] error -> AnyPublisher<[ChatRoomDTO], ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: ChatAPI.fetchChatRoom) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    

    private func request<T: Decodable>(_ api: LandAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
