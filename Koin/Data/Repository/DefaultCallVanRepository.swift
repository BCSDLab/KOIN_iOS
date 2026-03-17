//
//  DefaultCallVanRepository.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

final class DefaultCallVanRepository: CallVanRepository {
    
    private let service: CallVanService
    
    init(service: CallVanService) {
        self.service = service
    }
    
    func fetchCallVanList(request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse> {
        let request = CallVanListRequestDto(from: request)
        return service.fetchCallVanList(request)
            .map {
                $0.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchNotification() -> AnyPublisher<[CallVanNotification], ErrorResponse> {
        return service.fetchNotification()
            .map {
                $0.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    func postNotificationRead(notificationId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.postNotificationRead(notificationId)
    }
    
    func postAllNotificationsRead() -> AnyPublisher<Void, ErrorResponse> {
        return service.postAllNotificationsRead()
    }
    
    func deleteNotification(notificationId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.deleteNotification(notificationId)
    }
    
    func deleteAllNotifications() -> AnyPublisher<Void, ErrorResponse> {
        return service.deleteAllNotifications()
    }
    
    func postData(request: CallVanPostRequest) -> AnyPublisher<CallVanListPost, ErrorResponse> {
        let request = CallVanPostRequestDto(from: request)
        return service.postData(request)
            .map {
                $0.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    func participate(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.participate(postId: postId)
    }
    
    func quit(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.quit(postId: postId)
    }
    
    func close(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.close(postId: postId)
    }
    
    func reopen(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.reopen(postId: postId)
    }
    
    func complete(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.complete(postId: postId)
    }
    
    func fetchCallVanData(postId: Int) -> AnyPublisher<CallVanData, ErrorResponse> {
        return service.fetchCallVanData(postId: postId)
            .map {
                $0.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    func report(postId: Int, request: CallVanReportRequest) -> AnyPublisher<Void, ErrorResponse> {
        let request = CallVanReportRequestDto(from: request)
        return service.report(postId: postId, request: request)
    }
    
    func fetchCallVanChat(postId: Int) -> AnyPublisher<CallVanChat, ErrorResponse> {
        return service.fetchCallVanChat(postId: postId)
            .map {
                $0.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    func postCallVanChat(postId: Int, request: CallVanChatRequest) -> AnyPublisher<Void, ErrorResponse> {
        let request = CallVanChatRequestDto(from: request)
        return service.postCallVanChat(postId: postId, request: request)
    }
}
