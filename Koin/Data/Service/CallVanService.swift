//
//  CallVanService.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol CallVanService {
    func fetchCallVanList(_ request: CallVanListRequestDto) -> AnyPublisher<CallVanListDto, ErrorResponse>
    func fetchNotification() -> AnyPublisher<[CallVanNotificationDto], ErrorResponse>
}

final class DefaultCallVanService: CallVanService {
    
    private let networkService = NetworkService.shared
    
    func fetchCallVanList(_ request: CallVanListRequestDto) -> AnyPublisher<CallVanListDto, ErrorResponse> {
        return networkService.requestWithResponse(api: CallVanAPI.fetchCallVanList(request))
    }
    func fetchNotification() -> AnyPublisher<[CallVanNotificationDto], ErrorResponse> {
        return networkService.requestWithResponse(api: CallVanAPI.fetchNotification)
    }
}
