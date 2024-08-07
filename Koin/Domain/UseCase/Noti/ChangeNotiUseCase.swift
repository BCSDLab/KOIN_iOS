//
//  ChangeNotiUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Alamofire
import Combine

protocol ChangeNotiUseCase {
    func execute(method: Alamofire.HTTPMethod, type: SubscribeType) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultChangeNotiUseCase: ChangeNotiUseCase {
    
    private let notiRepository: NotiRepository
    
    init(notiRepository: NotiRepository) {
        self.notiRepository = notiRepository
    }
    
    func execute(method: Alamofire.HTTPMethod, type: SubscribeType) -> AnyPublisher<Void, ErrorResponse> {
        return notiRepository.changeNoti(method: method, requestModel: NotiSubscribeRequest(type: type))
    }
    
}
