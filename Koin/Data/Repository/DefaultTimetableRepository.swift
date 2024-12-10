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
    
    func deleteLecture(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        service._deleteLecture(id: id)
    }
    
    func deleteSemester(semester: String) -> AnyPublisher<Void, ErrorResponse> {
        service.deleteSemester(semester: semester)
    }
    
    func deleteLecture(frameId: Int, lectureId: Int) -> AnyPublisher<Void, ErrorResponse> {
        service.deleteLecture(frameId: frameId, lectureId: lectureId)
    }
    
    func fetchMySemester() -> AnyPublisher<MySemesterDTO, ErrorResponse> {
        service.fetchMySemester()
    }
    
    func fetchLectureList(semester: String) -> AnyPublisher<[SemesterLecture], Error> {
        service.fetchLectureList(semester: semester)
    }
    
    func fetchSemester() -> AnyPublisher<[SemesterDTO], Error> {
        service.fetchSemester()
    }
    
    func fetchDeptList() -> AnyPublisher<[DeptDTO], Error> {
        return service.fetchDeptList()
    }
    
    func fetchFrame(semester: String) -> AnyPublisher<[FrameDTO], ErrorResponse> {
        service.fetchFrame(semester: semester)
    }
    
    func deleteFrame(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        service.deleteFrame(id: id)
    }
    
    func createFrame(semester: String) -> AnyPublisher<FrameDTO, ErrorResponse> {
        service.createFrame(semester: semester)
    }
    
    func modifyFrame(frame: FrameDTO) -> AnyPublisher<FrameDTO, ErrorResponse> {
        service.modifyFrame(frame: frame)
    }
    
    func fetchLecture(frameId: Int) -> AnyPublisher<LectureDTO, ErrorResponse> {
        service.fetchLecture(frameId: frameId)
    }
    
    func modifyLecture(request: LectureRequest) -> AnyPublisher<LectureDTO, ErrorResponse> {
        service.modifyLecture(request: request)
    }
    
    func postLecture(request: LectureRequest) -> AnyPublisher<LectureDTO, ErrorResponse> {
        service.postLecture(request: request)
    }
    
    func rollbackFrame(id: Int) -> AnyPublisher<LectureDTO, ErrorResponse> {
        service.rollbackFrame(id: id)
    }
}
