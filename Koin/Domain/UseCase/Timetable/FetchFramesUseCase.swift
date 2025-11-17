//
//  FetchFramesUseCase.swift
//  koin
//
//  Created by 김나훈 on 12/10/24.
//

import Combine

protocol FetchFramesUseCase {
    func execute() -> AnyPublisher<[FrameData], ErrorResponse>
}

final class DefaultFetchFramesUseCase: FetchFramesUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute() -> AnyPublisher<[FrameData], ErrorResponse> {
        return timetableRepository.fetchAllFrames()
            .map { semestersDto in
                return self.sortFrames(semestersDto.toDomain())
            }
            .eraseToAnyPublisher()
    }
    
    private func sortFrames(_ frames: [FrameData]) -> [FrameData] {
        func sortSemester(_ semester: String) -> (year: Int, priority: Int) {
            var year = 0
            var priority = 0
            
            if let yearValue = Int(semester.prefix(4)) {
                year = yearValue
                if semester.hasSuffix("2") {
                    priority = 1
                } else if semester.hasSuffix("1") {
                    priority = 3
                }
            }
            
            if semester.contains("여름") {
                year = Int(semester.prefix(4)) ?? 0
                priority = 2
            } else if semester.contains("겨울") {
                year = Int(semester.prefix(4)) ?? 0
                priority = 0
            }
            
            return (year, priority)
        }
        
        return frames.sorted {
            let left = sortSemester($0.semester)
            let right = sortSemester($1.semester)
            if left.year == right.year {
                return left.priority < right.priority
            }
            return left.year > right.year
        }
    }
}
