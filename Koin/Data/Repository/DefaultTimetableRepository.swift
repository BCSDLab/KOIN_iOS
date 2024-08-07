//
//  DefaultTimetableRepository.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Combine

final class DefaultTimetableRepository: TimetableRepository {
    
    private let service: TimetableService
    
    init(service: TimetableService) {
        self.service = service
    }
    
    func fetchDeptList() -> AnyPublisher<[DeptDTO], Error> {
        return service.fetchDeptList()
    }
}
