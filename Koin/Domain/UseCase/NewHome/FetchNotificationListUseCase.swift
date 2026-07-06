//
//  FetchHomeDiningListUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Combine
import Foundation

protocol FetchNotificationListUseCase {
    func execute() -> AnyPublisher<[NotificationItem], ErrorResponse>
}

final class MockFetchNotificationListUseCase: FetchNotificationListUseCase {
    func execute() -> AnyPublisher<[NotificationItem], ErrorResponse> {
        
        let items = [
            NotificationItem(id: 1, isRead: false, icon: .notificationCallVan, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            NotificationItem(id: 2, isRead: false, icon: .notificationLostItem, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자콜밴팟 새 참여자콜밴팟 새 참여자콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            NotificationItem(id: 3, isRead: false, icon: .notificationChat, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.OOO님이 콜벤팟에 참여했어요.OOO님이 콜벤팟에 참여했어요.OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            NotificationItem(id: 4, isRead: false, icon: .notificationChat, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자콜밴팟 새 참여자콜밴팟 새 참여자콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.OOO님이 콜벤팟에 참여했어요.OOO님이 콜벤팟에 참여했어요.OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            
            NotificationItem(id: 5, isRead: false, icon: .notificationShop, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            NotificationItem(id: 6, isRead: false, icon: .notificationDining, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            
            NotificationItem(id: 7, isRead: true, icon: .notificationCallVan, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            NotificationItem(id: 8, isRead: true, icon: .notificationLostItem, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            NotificationItem(id: 9, isRead: true, icon: .notificationChat, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            NotificationItem(id: 10, isRead: true, icon: .notificationShop, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
            NotificationItem(id: 11, isRead: true, icon: .notificationDining, appPath: .callvan, uri: nil, title: "콜밴팟 새 참여자", content: "OOO님이 콜벤팟에 참여했어요.", dateText: "2시간 전"),
        ]
        
        return Just(items)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
}

