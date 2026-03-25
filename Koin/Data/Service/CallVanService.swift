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
    func fetchCallVanData(postId: Int) -> AnyPublisher<CallVanDataDto, ErrorResponse>
    func report(postId: Int, request: CallVanReportRequestDto) -> AnyPublisher<Void, ErrorResponse>
    func fetchCallVanChat(postId: Int) -> AnyPublisher<CallVanChatDto, ErrorResponse>
    func postCallVanChat(postId: Int, request: CallVanChatRequestDto) -> AnyPublisher<Void, ErrorResponse>
    func fetchCallVanSummary(postId: Int) -> AnyPublisher<CallVanSummaryDto, ErrorResponse>
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
    
    func fetchCallVanData(postId: Int) -> AnyPublisher<CallVanDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: CallVanAPI.fetchCallVanData(postId))
    }
    
    func report(postId: Int, request: CallVanReportRequestDto) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.report(postId, request))
    }
    
    func fetchCallVanChat(postId: Int) -> AnyPublisher<CallVanChatDto, ErrorResponse> {
        return networkService.requestWithResponse(api: CallVanAPI.fetchCallVanChat(postId))
    }
    
    func postCallVanChat(postId: Int, request: CallVanChatRequestDto) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: CallVanAPI.postCallVanChat(postId, request))
    }
    
    func fetchCallVanSummary(postId: Int) -> AnyPublisher<CallVanSummaryDto, ErrorResponse> {
        return networkService.requestWithResponse(api: CallVanAPI.fetchCallVanSummary(postId))
    }
}
