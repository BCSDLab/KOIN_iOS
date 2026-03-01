//
//  NotiService.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Alamofire
import Combine

protocol NotiService {
    func changeNoti(method: Alamofire.HTTPMethod, requestModel: NotiSubscribeRequest) -> AnyPublisher<Void, ErrorResponse>
    func changeNotiDetail(method: Alamofire.HTTPMethod, requestModel: NotiSubscribeDetailRequest) -> AnyPublisher<Void, ErrorResponse>
    func fetchNotiList() -> AnyPublisher<NotiAgreementDto, ErrorResponse>
}


final class DefaultNotiService: NotiService {
    
    private let networkService = NetworkService()
    
    private func sendDeviceToken() -> AnyPublisher<Void, ErrorResponse> {
            return networkService.request(api: NotiAPI.sendDeviceToken)
                .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                    guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                    if error.code == "401" {
                        return self.networkService.refreshToken()
                            .flatMap { _ in self.networkService.request(api: NotiAPI.sendDeviceToken) }
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }
        
        func changeNoti(method: Alamofire.HTTPMethod, requestModel: NotiSubscribeRequest) -> AnyPublisher<Void, ErrorResponse> {
            return sendDeviceToken() // 1. 먼저 sendDeviceToken()을 호출
                .flatMap { [weak self] _ -> AnyPublisher<Void, ErrorResponse> in
                    guard let self = self else { return Fail(error: ErrorResponse(code: "500", message: "Unexpected error")).eraseToAnyPublisher() }
                    return self.networkService.request(api: NotiAPI.changeNoti(method, requestModel)) // 2. 성공하면 changeNoti 호출
                }
                .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                    guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                    if error.code == "401" {
                        return self.networkService.refreshToken()
                            .flatMap { _ in self.networkService.request(api: NotiAPI.changeNoti(method, requestModel)) }
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }
    
    func changeNotiDetail(method: Alamofire.HTTPMethod, requestModel: NotiSubscribeDetailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: NotiAPI.changeNotiDetail(method, requestModel))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: NotiAPI.changeNotiDetail(method, requestModel)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchNotiList() -> AnyPublisher<NotiAgreementDto, ErrorResponse> {
        return networkService.requestWithResponse(api: NotiAPI.fetchNotiList)
            .catch { [weak self] error -> AnyPublisher<NotiAgreementDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: NotiAPI.fetchNotiList) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
}
