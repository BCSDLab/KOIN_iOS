//
//  CallVanRepository.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol CallVanRepository {
    func fetchCallVanList(_ request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse>
    func fetchNotification() -> AnyPublisher<[CallVanNotification], ErrorResponse>
}
