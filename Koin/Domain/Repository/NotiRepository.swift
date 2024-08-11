//
//  NotiRepository.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Alamofire
import Combine

protocol NotiRepository {
    func changeNoti(method: Alamofire.HTTPMethod, requestModel: NotiSubscribeRequest) -> AnyPublisher<Void, ErrorResponse>
    func changeNotiDetail(method: Alamofire.HTTPMethod, requestModel: NotiSubscribeDetailRequest) -> AnyPublisher<Void, ErrorResponse>
    func fetchNotiList() -> AnyPublisher<NotiAgreementDTO, ErrorResponse>
}


