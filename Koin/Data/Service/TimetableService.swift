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
            .catch { [weak self] error -> AnyPublisher<SemestersDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: TimetableAPI.fetchAllFrames) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func rollbackFrame(id: Int) -> AnyPublisher<LectureDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.rollbackFrame(id: id))
            .catch { [weak self] error -> AnyPublisher<LectureDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: TimetableAPI.rollbackFrame(id: id)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func _deleteLecture(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: TimetableAPI._deleteLecture(id: id))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: TimetableAPI._deleteLecture(id: id)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteLecture(frameId: Int, lectureId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: TimetableAPI.deleteLecture(frameId: frameId, lectureId: lectureId))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: TimetableAPI.deleteLecture(frameId: frameId, lectureId: lectureId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteSemester(semester: String) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: TimetableAPI.deleteSemester(semester: semester))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: TimetableAPI.deleteSemester(semester: semester)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchMySemester() -> AnyPublisher<MySemesterDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchMySemester)
            .catch { [weak self] error -> AnyPublisher<MySemesterDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: TimetableAPI.fetchMySemester) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchLectureList(semester: String) -> AnyPublisher<[SemesterLecture], Error> {
        request(.fetchLectureList(semester: semester))
    }
    
    func fetchSemester() -> AnyPublisher<[SemesterDto], Error> {
        request(.fetchSemester)
    }
    func fetchDeptList() -> AnyPublisher<[DeptDto], Error> {
        return request(.fetchDeptList)
    }
    
    func fetchLecture(frameId: Int) -> AnyPublisher<LectureDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchLecture(frameId: frameId))
            .catch { [weak self] error -> AnyPublisher<LectureDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: TimetableAPI.fetchLecture(frameId: frameId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func modifyLecture(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.modifyLecture(request: request))
            .catch { [weak self] error -> AnyPublisher<LectureDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: TimetableAPI.modifyLecture(request: request)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func postLecture(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.postLecture(request: request))
            .catch { [weak self] error -> AnyPublisher<LectureDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: TimetableAPI.postLecture(request: request)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchFrame(semester: String) -> AnyPublisher<[FrameDto], ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchFrame(semester: semester))
            .catch { [weak self] error -> AnyPublisher<[FrameDto], ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: TimetableAPI.fetchFrame(semester: semester)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func createFrame(semester: String) -> AnyPublisher<FrameDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.createFrame(semester: semester))
            .catch { [weak self] error -> AnyPublisher<FrameDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: TimetableAPI.createFrame(semester: semester)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func modifyFrame(frame: FrameDto) -> AnyPublisher<FrameDto, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.modifyFrame(frame: frame))
            .catch { [weak self] error -> AnyPublisher<FrameDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: TimetableAPI.modifyFrame(frame: frame)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteFrame(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: TimetableAPI.deleteFrame(id: id))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: TimetableAPI.deleteFrame(id: id)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
   
    private func request<T: Decodable>(_ api: TimetableAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
