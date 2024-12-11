//
//  FetchLectureListUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol FetchLectureListUseCase {
    func execute(semester: String) -> AnyPublisher<[SemesterLecture], Error>
}

final class DefaultFetchLectureListUseCase: FetchLectureListUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(semester: String) -> AnyPublisher<[SemesterLecture], Error> {
        return timetableRepository.fetchLectureList(semester: semester)
    }
    
}
