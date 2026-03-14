//
//  CallVanPlace.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation

enum CallVanPlace: String, CallVanFilterState {
    case all = "전체"
    case frontGate = "정문"
    case backGate = "후문"
    case tennisCourt = "테니스장"
    case dormitoryMain = "본관동"
    case dormitorySub = "별관동"
    case terminal = "천안터미널"
    case station = "천안역"
    case asanStation = "천안아산역"
    case custom = "기타"
}

