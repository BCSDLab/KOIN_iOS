//
//  CallVanPostRequest.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation

struct CallVanPostRequest {
    var departureType: CallVanPlace?
    var departureCustomName: String?
    var arrivalType: CallVanPlace?
    var arrivalCustomName: String?
    var departureDate: String? // "yyyy-MM-dd"
    var departureTime: String? // "HH:mm"
    var maxParticipants: Int = 2
}
