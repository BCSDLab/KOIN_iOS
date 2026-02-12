//
//  TimetableService.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Alamofire
import Combine

protocol TimetableService {
    func fetchDeptList() -> AnyPublisher<[DeptDto], Error>
    func fetchFrame(semester: String) -> AnyPublisher<[FrameDto], ErrorResponse>
    func deleteFrame(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func createFrame(semester: String) -> AnyPublisher<FrameDto, ErrorResponse>
    func modifyFrame(frame: FrameDto) -> AnyPublisher<FrameDto, ErrorResponse>
    func fetchLecture(frameId: Int) -> AnyPublisher<LectureDto, ErrorResponse>
    func modifyLecture(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse>
    func postLecture(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse>
    func fetchMySemester() -> AnyPublisher<MySemesterDto, ErrorResponse>
    func fetchLectureList(semester: String) -> AnyPublisher<[SemesterLecture], Error>
    func fetchSemester() -> AnyPublisher<[SemesterDto], Error>
    func deleteLecture(frameId: Int, lectureId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteSemester(semester: String) -> AnyPublisher<Void, ErrorResponse>
    func _deleteLecture(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func rollbackFrame(id: Int) -> AnyPublisher<LectureDto, ErrorResponse>
    func fetchAllFrames() -> AnyPublisher<SemestersDto, ErrorResponse>
}

final class DefaultTimetableService: TimetableService {
        
    private let networkService = NetworkService()
    
    func fetchAllFrames() -> AnyPublisher<SemestersDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchAllFrames)
    }
    
    func rollbackFrame(id: Int) -> AnyPublisher<LectureDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.rollbackFrame(id: id))
    }
    
    func _deleteLecture(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: TimetableAPI._deleteLecture(id: id))
    }
    
    func deleteLecture(frameId: Int, lectureId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: TimetableAPI.deleteLecture(frameId: frameId, lectureId: lectureId))
    }
    
    func deleteSemester(semester: String) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: TimetableAPI.deleteSemester(semester: semester))
    }
    
    func fetchMySemester() -> AnyPublisher<MySemesterDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchMySemester)
    }
    
    func fetchLectureList(semester: String) -> AnyPublisher<[SemesterLecture], Error> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchLectureList(semester: semester))
    }
    
    func fetchSemester() -> AnyPublisher<[SemesterDto], Error> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchSemester)
    }
    func fetchDeptList() -> AnyPublisher<[DeptDto], Error> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchDeptList)
    }
    
    func fetchLecture(frameId: Int) -> AnyPublisher<LectureDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchLecture(frameId: frameId))
    }
    
    func modifyLecture(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.modifyLecture(request: request))
    }
    
    func postLecture(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.postLecture(request: request))
    }
    
    func fetchFrame(semester: String) -> AnyPublisher<[FrameDto], ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchFrame(semester: semester))
    }
    
    func createFrame(semester: String) -> AnyPublisher<FrameDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.createFrame(semester: semester))
    }
    
    func modifyFrame(frame: FrameDto) -> AnyPublisher<FrameDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.modifyFrame(frame: frame))
    }
    
    func deleteFrame(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: TimetableAPI.deleteFrame(id: id))
    }
}
