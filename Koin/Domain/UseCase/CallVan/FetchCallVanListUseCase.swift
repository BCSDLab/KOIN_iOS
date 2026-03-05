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
        let postsDto = [
            CallVanListPostDto(postId: 1, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               state: CallVanStateDto.closed, isJoined: false, isAuthor: false),
            CallVanListPostDto(postId: 2, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               state: CallVanStateDto.closed, isJoined: true, isAuthor: false),
            CallVanListPostDto(postId: 3, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               state: CallVanStateDto.closed, isJoined: false, isAuthor: true),
            CallVanListPostDto(postId: 4, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               state: CallVanStateDto.completed, isJoined: false, isAuthor: false),
            CallVanListPostDto(postId: 5, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               state: CallVanStateDto.completed, isJoined: true, isAuthor: false),
            CallVanListPostDto(postId: 6, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               state: CallVanStateDto.completed, isJoined: false, isAuthor: true),
            CallVanListPostDto(postId: 7, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               state: CallVanStateDto.recruiting, isJoined: false, isAuthor: false),
            CallVanListPostDto(postId: 8, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               state: CallVanStateDto.recruiting, isJoined: true, isAuthor: false),
            CallVanListPostDto(postId: 9, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               state: CallVanStateDto.recruiting, isJoined: false, isAuthor: true)
        ]
        let callVanListDto = CallVanListDto(posts: postsDto, totalCount: 0, currentPage: 0, totalPage: 0)
        let callVanList = callVanListDto.toDomain()
        
        return Just(callVanList)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
}
