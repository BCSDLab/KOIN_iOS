//
//  CallVanRepository.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol CallVanRepository {
    func fetchCallVanList(request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse>
    func fetchNotification() -> AnyPublisher<[CallVanNotification], ErrorResponse>
    func postNotificationRead(notificationId: Int) -> AnyPublisher<Void, ErrorResponse>
    func postAllNotificationsRead() -> AnyPublisher<Void, ErrorResponse>
    func deleteNotification(notificationId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteAllNotifications() -> AnyPublisher<Void, ErrorResponse>
    func postData(request: CallVanPostRequest) -> AnyPublisher<CallVanListPost, ErrorResponse>
    func participate(postId: Int) -> AnyPublisher<Void, ErrorResponse>
    func quit(postId: Int) -> AnyPublisher<Void, ErrorResponse>
    func close(postId: Int) -> AnyPublisher<Void, ErrorResponse>
    func reopen(postId: Int) -> AnyPublisher<Void, ErrorResponse>
    func complete(postId: Int) -> AnyPublisher<Void, ErrorResponse>
    func fetchCallVanData(postId: Int) -> AnyPublisher<CallVanData, ErrorResponse>
    func report(postId: Int, request: CallVanReportRequest) -> AnyPublisher<Void, ErrorResponse>
    func fetchCallVanChat(postId: Int) -> AnyPublisher<CallVanChat, ErrorResponse>
    func postCallVanChat(postId: Int, request: CallVanChatRequest) -> AnyPublisher<Void, ErrorResponse>
    func fetchCallVanSummary(postId: Int) -> AnyPublisher<CallVanListPost, ErrorResponse>
    func fetchRestriction() -> AnyPublisher<CallVanRestriction, ErrorResponse>
}
