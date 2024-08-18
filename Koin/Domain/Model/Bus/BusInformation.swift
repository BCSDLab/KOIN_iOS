//
//  BusInformation.swift
//  koin
//
//  Created by 김나훈 on 7/18/24.
//

struct BusCardInformation {
    let busTitle: BusType
    let departedPlace: BusPlace
    let arrivedPlace: BusPlace
    let remainTime: String
    let departedTime: String?
    let busNumber: String?
    let nextBusInfo: NextBusInformation
}

struct NextBusInformation {
    let departedTime: String?
    let remainTime: String
    let busNumber: String?
}

struct BusInformation {
    let busType: BusType
    var startBusArea: BusPlace
    var endBusArea: BusPlace
    let redirectedText: String
    let color: SceneColorAsset
    let remainTime: String
    let departedTime: String?
}
