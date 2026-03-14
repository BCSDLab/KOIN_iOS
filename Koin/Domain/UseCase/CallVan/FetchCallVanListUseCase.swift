//
//  FetchCallVanListUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

protocol FetchCallVanListUseCase {
    func execute(request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse>
}

final class MockFetchCallVanListUseCase: FetchCallVanListUseCase {
    
    func execute(request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse> {
        let posts: [CallVanListPost] = [
            CallVanListPost(postId: 1, title: "A>B", departure: "테니스장", arrival: "시외버스터미널",
                            departureDate: "02.02", departureDay: "(수)", departureTime: "12:34",
                            authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                            mainState: .모집마감, subState: nil, showChatButton: false, showCallButton: false),
            
            CallVanListPost(postId: 2, title: "A>B", departure: "테니스장", arrival: "시외버스터미널",
                            departureDate: "02.02", departureDay: "(수)", departureTime: "12:34",
                            authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                            mainState: .모집마감, subState: nil, showChatButton: true, showCallButton: false),
            
            CallVanListPost(postId: 3, title: "A>B", departure: "테니스장", arrival: "시외버스터미널",
                            departureDate: "02.02", departureDay: "(수)", departureTime: "12:34",
                            authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                            mainState: .재모집, subState: .이용완료, showChatButton: false, showCallButton: true),
            
            CallVanListPost(postId: 7, title: "A>B", departure: "테니스장", arrival: "시외버스터미널",
                            departureDate: "02.02", departureDay: "(수)", departureTime: "12:34",
                            authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                            mainState: .참여하기, subState: nil, showChatButton: false, showCallButton: false),
            
            CallVanListPost(postId: 8, title: "A>B", departure: "테니스장", arrival: "시외버스터미널",
                            departureDate: "02.02", departureDay: "(수)", departureTime: "12:34",
                            authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                            mainState: .참여취소, subState: nil, showChatButton: true, showCallButton: false),
            
            CallVanListPost(postId: 9, title: "A>B", departure: "테니스장", arrival: "시외버스터미널",
                            departureDate: "02.02", departureDay: "(수)", departureTime: "12:34",
                            authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                            mainState: .마감하기, subState: nil, showChatButton: false, showCallButton: true)
        ]
        
        let callVanList = CallVanList(posts: posts, totalCount: 0, currentPage: 0, totalPage: 0)
        
        return Just(callVanList)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
}
