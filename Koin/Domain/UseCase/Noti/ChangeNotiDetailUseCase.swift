//
//  ChangeNotiDetailUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Alamofire
import Combine

protocol ChangeNotiDetailUseCase {
    func execute(method: Alamofire.HTTPMethod, detailType: DetailSubscribeType) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultChangeNotiDetailUseCase: ChangeNotiDetailUseCase {
    
    private let notiRepository: NotiRepository
    
    init(notiRepository: NotiRepository) {
        self.notiRepository = notiRepository
    }
    
    func execute(method: Alamofire.HTTPMethod, detailType: DetailSubscribeType) -> AnyPublisher<Void, ErrorResponse> {
        return notiRepository.changeNotiDetail(method: method, requestModel: NotiSubscribeDetailRequest(detailType: detailType))
    }
    
}
