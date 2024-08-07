//
//  TimetableService.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Alamofire
import Combine

protocol TimetableService {
    func fetchDeptList() -> AnyPublisher<[DeptDTO], Error>
}

final class DefaultTimetableService: TimetableService {
    
    func fetchDeptList() -> AnyPublisher<[DeptDTO], Error> {
        return request(.fetchDeptList)
    }

    private func request<T: Decodable>(_ api: TimetableAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
