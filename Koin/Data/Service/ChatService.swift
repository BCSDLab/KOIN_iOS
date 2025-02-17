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
    func fetchChatDetail(articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatDetailDTO], ErrorResponse>
}

final class DefaultChatService: ChatService {
    
    private let networkService = NetworkService()
    
    func fetchChatDetail(articleId: Int, chatRoomId: Int) -> AnyPublisher<[ChatDetailDTO], ErrorResponse> {
        return networkService.requestWithResponse(api: ChatAPI.fetchChatDetail(articleId, chatRoomId))
            .catch { [weak self] error -> AnyPublisher<[ChatDetailDTO], ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: ChatAPI.fetchChatDetail(articleId, chatRoomId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
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
