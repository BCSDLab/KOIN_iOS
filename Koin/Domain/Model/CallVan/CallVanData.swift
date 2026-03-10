//
//  CallVanData.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit

struct CallVanData {
    let id: Int
    let departure: String
    let arrival: String
    let dateTime: String
    let currentParticipants: Int
    let maxParticipants: Int
    let participants: [CallVanParticipant]
}

struct CallVanParticipant {
    let userId: Int
    let nickname: String
    let isMe: Bool
    let index: Int
    let profileImage: UIImage?
}
