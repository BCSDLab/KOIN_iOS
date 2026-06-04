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
            NotificationItem(
                id: 1,
                iconType: .breakfast,
                title: "천원의 아침",
                content: "곧 아침 배식 시간이 끝나요. 식당에서 바코드를 찍어보세요.",
                dateText: "2시간 전",
                badgeText: "2건"
            ),
            NotificationItem(
                id: 2,
                iconType: .board,
                title: "게시판",
                content: "내 게시글에 새로운 댓글 3개가 달렸어요.",
                dateText: "2시간 전",
                badgeText: "3건"
            ),
            NotificationItem(
                id: 3,
                iconType: .callvanpot,
                title: "콜벤팟",
                content: "4명 모집 완료 | 한기대 → 천안역",
                secondaryContent: "같이 탈 사람 모집이 끝났어요. 출발 시간과 장소를 확인해주세요.",
                dateText: "2시간 전",
                badgeText: "4건"
            ),
            NotificationItem(
                id: 4,
                iconType: .shuttleTicket,
                title: "셔틀 탑승권",
                content: "15분 뒤 버스가 출발해요. 승차 전 탑승권 QR을 미리 켜주세요.",
                dateText: "2시간 전",
                badgeText: nil
            ),
            NotificationItem(
                id: 5,
                iconType: .board,
                title: "게시판",
                content: "내 게시글에 새로운 댓글 3개가 달렸어요.",
                dateText: "2시간 전",
                badgeText: "3건"
            ),
            NotificationItem(
                id: 6,
                iconType: .breakfast,
                title: "천원의 아침",
                content: "곧 아침 배식 시간이 끝나요. 식당에서 바코드를 찍어보세요.",
                dateText: "2시간 전",
                badgeText: "2건"
            ),
            NotificationItem(
                id: 7,
                iconType: .breakfast,
                title: "천원의 아침",
                content: "곧 아침 배식 시간이 끝나요. 식당에서 바코드를 찍어보세요.",
                dateText: "2시간 전",
                badgeText: "2건"
            ),
            NotificationItem(
                id: 8,
                iconType: .breakfast,
                title: "천원의 아침",
                content: "곧 아침 배식 시간이 끝나요. 식당에서 바코드를 찍어보세요.",
                dateText: "2시간 전",
                badgeText: "2건"
            )
        ]
        
        return Just(items)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
}

