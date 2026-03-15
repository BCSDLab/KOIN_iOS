//
//  CallVanRepository.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol CallVanRepository {
    func fetchCallVanList(_ request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse>
    func fetchNotification() -> AnyPublisher<[CallVanNotification], ErrorResponse>
    func postNotificationRead(_ notificationId: Int) -> AnyPublisher<Void, ErrorResponse>
    func postAllNotificationsRead() -> AnyPublisher<Void, ErrorResponse>
    func deleteNotification(_ notificationId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteAllNotifications() -> AnyPublisher<Void, ErrorResponse>
    func postData(_ request: CallVanPostRequest) -> AnyPublisher<CallVanListPost, ErrorResponse>
}
