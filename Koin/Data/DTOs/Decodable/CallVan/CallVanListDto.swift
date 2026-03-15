//
//  CallVanListDto.swift
//  koin
//
//  Created by 홍기정 on 3/3/26.
//

import Foundation

struct CallVanListDto: Decodable {
    let posts: [CallVanListPostDto]
    let totalCount: Int
    let currentPage: Int
    let totalPage: Int
    
    enum CodingKeys: String, CodingKey {
        case posts
        case totalCount = "total_count"
        case currentPage = "current_page"
        case totalPage = "total_page"
    }
}

struct CallVanListPostDto: Decodable {
    let postId: Int
    let title: String
    let departure: String
    let arrival: String
    let departureDate: String
    let departureTime: String
    let authorNickname: String
    let currentParticipants: Int
    let maxParticipants: Int
    let state: CallVanStateDto
    let isJoined: Bool
    let isAuthor: Bool
    
    enum CodingKeys: String, CodingKey {
        case postId = "id"
        case title, departure, arrival
        case departureDate = "departure_date"
        case departureTime = "departure_time"
        case authorNickname = "author_nickname"
        case currentParticipants = "current_participants"
        case maxParticipants = "max_participants"
        case state = "status"
        case isJoined = "is_joined"
        case isAuthor = "is_author"
    }
}

enum CallVanStateDto: String, Codable {
    case recruiting = "RECRUITING"
    case closed = "CLOSED"
    case completed = "COMPLETED"
}

extension CallVanListDto {
    func toDomain() -> CallVanList {
        return CallVanList(
            posts: posts
                .map {
                    $0.toDomain()
                }
                .compactMap {
                    if let post = $0 {
                        return post
                    } else {
                        return nil
                    }
                }
            ,
            totalCount: totalCount,
            currentPage: currentPage,
            totalPage: totalPage
        )
    }
}

extension CallVanListPostDto {
    
    func toDomain() -> CallVanListPost? {
        let states = callVanState(state: state, isJoined: isJoined, isAuthor: isAuthor)
        guard let mainState = states.first else {
            return nil
        }
        let subState = {
            if states.first != states.last {
                return states.last
            } else {
                return nil
            }
        }()
        
        return CallVanListPost(
            postId: postId,
            title: title,
            departure: departure,
            arrival: arrival,
            departureDate: displayDate(departureDate),
            departureDay: displayDay(departureDate),
            departureTime: departureTime,
            authorNickname: authorNickname,
            currentParticipants: currentParticipants,
            maxParticipants: maxParticipants,
            mainState: mainState,
            subState: subState,
            showChatButton: showChatButton(state: state, isJoined: isJoined, isAuthor: isAuthor),
            showCallButton: showCallButton(state: state, isJoined: isJoined, isAuthor: isAuthor)
        )
    }
    
    func displayDate(_ inputDate: String) -> String {
        let inputFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd"
        }
        let displayFormatter = DateFormatter().then {
            $0.dateFormat = "MM.dd"
        }
        
        if let date = inputFormatter.date(from: inputDate) {
            return displayFormatter.string(from: date)
        } else {
            return "DATE"
        }
    }
    
    func displayDay(_ inputDate: String) -> String {
        let inputFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd"
        }
        let displayFormatter = DateFormatter().then {
            $0.dateFormat = "(E)"
            $0.locale = Locale(identifier: "ko_KR")
        }
        
        if let date = inputFormatter.date(from: inputDate) {
            return displayFormatter.string(from: date)
        } else {
            return "DAY"
        }
    }
    
    func callVanState(state: CallVanStateDto, isJoined: Bool, isAuthor: Bool) -> [CallVanState] {
        switch (isAuthor, state, isJoined) {
        case (true, .recruiting, _): return [.마감하기]
        case (true, .closed, _): return [.재모집, .이용완료]
        case (true, .completed, _): return []
        case (false, .recruiting, false): return [.참여하기]
        case (false, .recruiting, true): return [.참여취소]
        case (false, .closed, _): return [.모집마감]
        case (false, .completed, _): return []
        }
    }
    
    func showChatButton(state: CallVanStateDto, isJoined: Bool, isAuthor: Bool) -> Bool {
        switch (isAuthor, state, isJoined) {
        case (false, _, true): return true
        default: return false
        }
    }
    
    func showCallButton(state: CallVanStateDto, isJoined: Bool, isAuthor: Bool) -> Bool {
        switch (isAuthor, state, isJoined) {
        case (true, .recruiting, _): return true
        case (true, .closed, _): return true
        default: return false
        }
    }
}

