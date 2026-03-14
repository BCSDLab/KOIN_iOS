//
//  FetchCallVanParticipants.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import Combine

protocol FetchCallVanDataUseCase {
    func execute(postId: Int) -> AnyPublisher<CallVanData, ErrorResponse>
}


final class MockFetchCallVanDataUseCase: FetchCallVanDataUseCase {
    func execute(postId: Int) -> AnyPublisher<CallVanData, ErrorResponse> {
        return Just(CallVanData(
            id: 1,
            departure: "출발: 복지관",
            arrival: "도착: 천안역",
            dateTime: "03.24 (월) 14:00",
            currentParticipants: 6,
            maxParticipants: 8,
            participants: [
                CallVanParticipant(userId: 12, nickname: "홍길동 (나)", isMe: true, index: -1, profileImage: UIImage.appImage(asset: .callVanProfileMine)),
                CallVanParticipant(userId: 14, nickname: "신짱구", isMe: false, index: 0, profileImage: UIImage.appImage(asset: .callVanProfile0)),
                CallVanParticipant(userId: 14, nickname: "김철수", isMe: false, index: 0, profileImage: UIImage.appImage(asset: .callVanProfile1)),
                CallVanParticipant(userId: 14, nickname: "한유리", isMe: false, index: 0, profileImage: UIImage.appImage(asset: .callVanProfile2))
            ]
        ))
        .setFailureType(to: ErrorResponse.self)
        .eraseToAnyPublisher()
    }
}
