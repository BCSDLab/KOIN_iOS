//
//  LandDetailDTO.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//  Nullable 2024.04.26

import Foundation

struct LandDetailDTO: Decodable {
    let optElectronicDoorLocks, optTv: Bool
    let monthlyFee: String?
    let optElevator, optWaterPurifier, optWasher: Bool
    let latitude: Double?
    let charterFee: String?
    let optVeranda: Bool
    let createdAt: String
    let description: String?
    let imageUrls: [String]?
    let optGasRange, optInduction: Bool
    let internalName: String?
    let isDeleted: Bool
    let updatedAt: String
    let optBidet, optShoeCloset, optRefrigerator: Bool
    let id: Int
    let floor: Int?
    let managementFee: String?
    let optDesk, optCloset: Bool
    let longitude: Double?
    let address: String?
    let optBed: Bool
    let size: String?
    let phone: String?
    let optAirConditioner: Bool
    let name: String?
    let deposit: String?
    let optMicrowave: Bool
    let permalink, roomType: String?

    enum CodingKeys: String, CodingKey {
        case optElectronicDoorLocks = "opt_electronic_door_locks"
        case optTv = "opt_tv"
        case monthlyFee = "monthly_fee"
        case optElevator = "opt_elevator"
        case optWaterPurifier = "opt_water_purifier"
        case optWasher = "opt_washer"
        case latitude
        case charterFee = "charter_fee"
        case optVeranda = "opt_veranda"
        case createdAt = "created_at"
        case description
        case imageUrls = "image_urls"
        case optGasRange = "opt_gas_range"
        case optInduction = "opt_induction"
        case internalName = "internal_name"
        case isDeleted = "is_deleted"
        case updatedAt = "updated_at"
        case optBidet = "opt_bidet"
        case optShoeCloset = "opt_shoe_closet"
        case optRefrigerator = "opt_refrigerator"
        case id, floor
        case managementFee = "management_fee"
        case optDesk = "opt_desk"
        case optCloset = "opt_closet"
        case longitude, address
        case optBed = "opt_bed"
        case size, phone
        case optAirConditioner = "opt_air_conditioner"
        case name, deposit
        case optMicrowave = "opt_microwave"
        case permalink
        case roomType = "room_type"
    }
    func toDomain() -> LandDetailItem {
        let charterFeeText: String
        let depositText: String
        let floorText: String
        let sizeText: String
        let isOptionExists: [Bool] = [optAirConditioner, optRefrigerator, optCloset, optTv, optMicrowave, optGasRange, optInduction, optWaterPurifier, optWasher, optBed, optDesk, optShoeCloset, optElectronicDoorLocks, optBidet, optVeranda, optElevator]
        if let charterFee = charterFee { charterFeeText = "\(charterFee)만원" }
        else { charterFeeText = "-" }
        if let deposit = deposit { depositText = "\(deposit)만원" }
        else { depositText = "-" }
        if let floor = floor { floorText = "\(floor)층" }
        else { floorText = "-" }
        if let size = size { sizeText = "\(size)평" }
        else { sizeText = "-" }
        let roomOptionInfo: [String] = [monthlyFee ?? "", roomType ?? "-", charterFeeText, depositText, floorText, managementFee ?? "-", sizeText, phone ?? "-"]
        return .init(roomOptionInfo: roomOptionInfo, landName: name ?? "-", imageUrls: imageUrls ?? [], address: address ?? "-", isOptionExists: isOptionExists, longitude: longitude ?? 0.0, latitude: latitude ?? 0.0)
    }
}
