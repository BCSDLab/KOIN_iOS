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
    let id: Int
    let title: String
    let departure: String
    let arrival: String
    let departureDate: String
    let departureTime: String
    let authorNickname: String
    let currentParticipants: Int
    let maxParticipants: Int
    let status: CallVanStateDto
    let isJoined: Bool
    let isAuthor: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, departure, arrival
        case departureDate = "departure_date"
        case departureTime = "departure_time"
        case authorNickname = "author_nickname"
        case currentParticipants = "current_participants"
        case maxParticipants = "max_participants"
        case status
        case isJoined = "is_joined"
        case isAuthor = "is_author"
    }
}

enum CallVanStateDto: String, Codable {
    case recruiting = "RECRUITING"
    case closed = "CLOSED"
    case completed = "COMPLETED"
    
    var description: String {
        switch self {
        case .recruiting: return "모집중"
        case .closed: return "모집마감"
        case .completed: return "종료됨"
        }
    }
    
    init?(description: String) {
        switch description {
        case "모집중": self = .recruiting
        case "모집마감": self = .closed
        case "종료됨": self = .completed
        default: return nil
        }
    }
}

extension CallVanListDto {
    func toDomain() -> CallVanList {
        return CallVanList(
            posts: posts
                .map {
                    $0.toDomain()
                }
                .filter {
                    $0.status.count != 0
                }
            ,
            totalCount: totalCount,
            currentPage: currentPage,
            totalPage: totalPage
        )
    }
}

extension CallVanListPostDto {
    
    func toDomain() -> CallVanListPost {
        return CallVanListPost(
            id: id,
            title: title,
            departure: departure,
            arrival: arrival,
            departureDate: displayDate(departureDate),
            departureDay: displayDay(departureDate),
            departureTime: departureTime,
            authorNickname: authorNickname,
            currentParticipants: currentParticipants,
            maxParticipants: maxParticipants,
            status: callVanState(status: status, isJoined: isJoined, isAuthor: isAuthor),
            showChatButton: showChatButton(status: status, isJoined: isJoined, isAuthor: isAuthor),
            showCallButton: showCallButton(status: status, isJoined: isJoined, isAuthor: isAuthor)
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
    
    func callVanState(status: CallVanStateDto, isJoined: Bool, isAuthor: Bool) -> [CallVanState] {
        switch (isAuthor, status, isJoined) {
        case (true, .recruiting, _): return [.마감하기]
        case (true, .closed, _): return [.재모집, .이용완료]
        case (true, .completed, _): return []
        case (false, .recruiting, false): return [.참여하기]
        case (false, .recruiting, true): return [.참여취소]
        case (false, .closed, _): return [.모집마감]
        case (false, .completed, _): return []
        }
    }
    
    func showChatButton(status: CallVanStateDto, isJoined: Bool, isAuthor: Bool) -> Bool {
        switch (isAuthor, status, isJoined) {
        case (false, _, true): return true
        default: return false
        }
    }
    
    func showCallButton(status: CallVanStateDto, isJoined: Bool, isAuthor: Bool) -> Bool {
        switch (isAuthor, status, isJoined) {
        case (true, .recruiting, _): return true
        case (true, .closed, _): return true
        default: return false
        }
    }
}

