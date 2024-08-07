//
//  TimetableRepository.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Combine

protocol TimetableRepository {
    func fetchDeptList() -> AnyPublisher<[DeptDTO], Error>
}
