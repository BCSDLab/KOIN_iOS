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
    
    func fetchAllFrames() -> AnyPublisher<SemestersDto, ErrorResponse> {
        service.fetchAllFrames()
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
    
    func fetchMySemester() -> AnyPublisher<MySemesterDto, ErrorResponse> {
        service.fetchMySemester()
    }
    
    func fetchLectureList(semester: String) -> AnyPublisher<[SemesterLecture], Error> {
        service.fetchLectureList(semester: semester)
    }
    
    func fetchSemester() -> AnyPublisher<[SemesterDto], Error> {
        service.fetchSemester()
    }
    
    func fetchDeptList() -> AnyPublisher<[DeptDto], Error> {
        return service.fetchDeptList()
    }
    
    func fetchFrame(semester: String) -> AnyPublisher<[FrameDto], ErrorResponse> {
        service.fetchFrame(semester: semester)
    }
    
    func deleteFrame(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        service.deleteFrame(id: id)
    }
    
    func createFrame(semester: String) -> AnyPublisher<FrameDto, ErrorResponse> {
        service.createFrame(semester: semester)
    }
    
    func modifyFrame(frame: FrameDto) -> AnyPublisher<FrameDto, ErrorResponse> {
        service.modifyFrame(frame: frame)
    }
    
    func fetchLecture(frameId: Int) -> AnyPublisher<LectureDto, ErrorResponse> {
        service.fetchLecture(frameId: frameId)
    }
    
    func modifyLecture(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse> {
        service.modifyLecture(request: request)
    }
    
    func postLecture(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse> {
        service.postLecture(request: request)
    }
    
    func rollbackFrame(id: Int) -> AnyPublisher<LectureDto, ErrorResponse> {
        service.rollbackFrame(id: id)
    }
}
