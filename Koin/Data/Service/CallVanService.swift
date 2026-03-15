//
//  CallVanService.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol CallVanService {
    func fetchCallVanList(_ request: CallVanListRequestDto) -> AnyPublisher<CallVanListDto, ErrorResponse>
    func fetchNotification() -> AnyPublisher<[CallVanNotificationDto], ErrorResponse>
    func postNotificationRead(_ notificationId: Int) -> AnyPublisher<Void, ErrorResponse>
    func postAllNotificationsRead() -> AnyPublisher<Void, ErrorResponse>
    func deleteNotification(_ notificationId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteAllNotifications() -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultCallVanService: CallVanService {
    
    private let networkService = NetworkService.shared
    
    func fetchCallVanList(_ request: CallVanListRequestDto) -> AnyPublisher<CallVanListDto, ErrorResponse> {
        return networkService.requestWithResponse(api: CallVanAPI.fetchCallVanList(request))
    }
    
    func fetchNotification() -> AnyPublisher<[CallVanNotificationDto], ErrorResponse> {
        return networkService.requestWithResponse(api: CallVanAPI.fetchNotification)
    }
    
    func postNotificationRead(_ notificationId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.postNotificationRead(notificationId))
    }
    
    func postAllNotificationsRead() -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.postAllNotificationsRead)
    }
    
    func deleteNotification(_ notificationId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.deleteNotification(notificationId))
    }
    
    func deleteAllNotifications() -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.deleteAllNotifications)
    }
}
