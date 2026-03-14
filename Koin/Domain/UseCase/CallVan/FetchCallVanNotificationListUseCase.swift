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

import Combine
import Foundation

final class MockFetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase {
    
    func execute() -> AnyPublisher<[CallVanNotification], ErrorResponse> {
        let notifications: [CallVanNotification] = [
            CallVanNotification(
                id: 0,
                postId: 1,
                type: .recruitmentCompleted,
                isRead: true,
                description: "02.02(수) 22:22 학교 - 학교",
                currentParticipants: 4,
                maxParticipants: 8,
                messagePreview: "해당 콜벤팟 인원이 모두 모집되었습니다. 콜벤을 예약하세요"
            ),
            
            CallVanNotification(
                id: 1,
                postId: 2,
                type: .newMessage,
                isRead: false,
                description: "02.02(수) 22:22 학교 - 학교",
                currentParticipants: 4,
                maxParticipants: 8,
                messagePreview: "익명: 안녕하세용?"
            ),
            
            CallVanNotification(
                id: 2,
                postId: 3,
                type: .paritipantJoined,
                isRead: true,
                description: "02.02(수) 22:22 학교 - 학교",
                currentParticipants: 4,
                maxParticipants: 8,
                messagePreview: "00님이 콜밴팟에 참여했어요."
            ),
            
            CallVanNotification(
                id: 3,
                postId: 4,
                type: .departureUpcoming,
                isRead: false,
                description: "02.02(수) 22:22 학교 - 학교",
                currentParticipants: 4,
                maxParticipants: 8,
                messagePreview: "해당 콜밴팟 출발 시간이 30분 남았어요."
            )
        ]
        
        return Just(notifications)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
}
