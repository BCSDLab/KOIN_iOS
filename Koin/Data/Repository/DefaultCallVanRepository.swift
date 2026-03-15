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
    
    func fetchCallVanList(_ request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse> {
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
    
    func postNotificationRead(_ notificationId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.postNotificationRead(notificationId)
    }
    
    func postAllNotificationsRead() -> AnyPublisher<Void, ErrorResponse> {
        return service.postAllNotificationsRead()
    }
    
    func deleteNotification(_ notificationId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.deleteNotification(notificationId)
    }
    
    func deleteAllNotifications() -> AnyPublisher<Void, ErrorResponse> {
        return service.deleteAllNotifications()
    }
    
    func postData(_ request: CallVanPostRequest) -> AnyPublisher<CallVanListPost, ErrorResponse> {
        let request = CallVanPostRequestDto(from: request)
        return service.postData(request)
            .map {
                $0.toDomain()
            }
            .eraseToAnyPublisher()
    }
}
