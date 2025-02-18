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
    func blockUser(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse>
    func createChatRoom(articleId: Int) -> AnyPublisher<CreateChatRoomResponse, ErrorResponse>
}

final class DefaultChatService: ChatService {
    func createChatRoom(articleId: Int) -> AnyPublisher<CreateChatRoomResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: ChatAPI.createChatRoom(articleId))
            .catch { [weak self] error -> AnyPublisher<CreateChatRoomResponse, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: ChatAPI.createChatRoom(articleId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    private let networkService = NetworkService()
    
    func blockUser(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ChatAPI.blockUser(articleId, chatRoomId))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: ChatAPI.blockUser(articleId, chatRoomId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
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
