//
//  DefaultNotiRepository.swift
//  koin
//
//  Created by 김나훈 on 7/28/24.
//
import Alamofire
import Combine

final class DefaultNotiRepository: NotiRepository {

    private let service: NotiService
    
    init(service: NotiService) {
        self.service = service
    }
    
    func sendDeviceToken() -> AnyPublisher<Void, ErrorResponse> {
        service.sendDeviceToken()
    }
    
    func changeNoti(method: Alamofire.HTTPMethod, requestModel: NotiSubscribeRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.changeNoti(method: method, requestModel: requestModel)
    }
    
    func changeNotiDetail(method: Alamofire.HTTPMethod, requestModel: NotiSubscribeDetailRequest) -> AnyPublisher<Void, ErrorResponse> {
        service.changeNotiDetail(method: method, requestModel: requestModel)
    }
    
    func fetchNotiList() -> AnyPublisher<NotiAgreementDTO, ErrorResponse> {
        service.fetchNotiList()
    }
    
}
