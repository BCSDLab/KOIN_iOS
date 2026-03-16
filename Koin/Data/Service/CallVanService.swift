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
    func postData(_ request: CallVanPostRequestDto) -> AnyPublisher<CallVanPostResultDto, ErrorResponse>
    func participate(postId: Int) -> AnyPublisher<Void, ErrorResponse>
    func quit(postId: Int) -> AnyPublisher<Void, ErrorResponse>
    func close(postId: Int) -> AnyPublisher<Void, ErrorResponse>
    func reopen(postId: Int) -> AnyPublisher<Void, ErrorResponse>
    func complete(postId: Int) -> AnyPublisher<Void, ErrorResponse>
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
    
    func postData(_ request: CallVanPostRequestDto) -> AnyPublisher<CallVanPostResultDto, ErrorResponse> {
        return networkService.requestWithResponse(api: CallVanAPI.postData(request))
    }
    
    func participate(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.participate(postId))
    }
    
    func quit(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.quit(postId))
    }
    
    func close(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.close(postId))
    }
    
    func reopen(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.reopen(postId))
    }
    
    func complete(postId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.complete(postId))
    }
}
