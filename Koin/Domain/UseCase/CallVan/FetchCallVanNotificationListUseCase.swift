//
//  FetchCallVanNotificationListUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

protocol FetchCallVanNotificationListUseCase {
    func execute() -> AnyPublisher<[CallVanNotification], ErrorResponse>
}

final class MockFetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase {
    func execute() -> AnyPublisher<[CallVanNotification], ErrorResponse> {
        let notificationdtos = [
            CallVanNotificationDto(id: 0,
                                   isRead: true,
                                   createdAt: "",
                                   type: .recruitmentCompleted,
                                   messagePreview: "해당 콜벤팟 인원이 모두 모집되었습니다. 콜벤을 예약하세요",
                                   senderNickname: nil,
                                   joinedMemberNickname: nil,
                                   postId: 1,
                                   departure: "학교",
                                   arrival: "학교",
                                   departureDate: "2022-02-02",
                                   departureTime: "22:22",
                                   currentParticipants: 4,
                                   maxParticipants: 8),
            CallVanNotificationDto(id: 0,
                                   isRead: false,
                                   createdAt: "",
                                   type: .newMessage,
                                   messagePreview: "안녕하세용?",
                                   senderNickname: "아무개",
                                   joinedMemberNickname: nil,
                                   postId: 2,
                                   departure: "학교",
                                   arrival: "학교",
                                   departureDate: "2022-02-02",
                                   departureTime: "22:22",
                                   currentParticipants: 4,
                                   maxParticipants: 8),
            CallVanNotificationDto(id: 0,
                                   isRead: true,
                                   createdAt: "",
                                   type: .paritipantJoined,
                                   messagePreview: nil,
                                   senderNickname: nil,
                                   joinedMemberNickname: "뉴비",
                                   postId: 3,
                                   departure: "학교",
                                   arrival: "학교",
                                   departureDate: "2022-02-02",
                                   departureTime: "22:22",
                                   currentParticipants: 4,
                                   maxParticipants: 8),
            CallVanNotificationDto(id: 0,
                                   isRead: false,
                                   createdAt: "",
                                   type: .departureUpcoming,
                                   messagePreview: nil,
                                   senderNickname: nil,
                                   joinedMemberNickname: nil,
                                   postId: 4,
                                   departure: "학교",
                                   arrival: "학교",
                                   departureDate: "2022-02-02",
                                   departureTime: "22:22",
                                   currentParticipants: 4,
                                   maxParticipants: 8)
        ]
        let notifications = notificationdtos.map { $0.toDomain() }
        return Just(notifications)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
}
