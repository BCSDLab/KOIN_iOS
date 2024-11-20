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
    func fetchFrame(semester: String) -> AnyPublisher<[FrameDTO], ErrorResponse>
    func deleteFrame(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func createFrame(semester: String) -> AnyPublisher<FrameDTO, ErrorResponse>
    func modifyFrame(frame: FrameDTO) -> AnyPublisher<FrameDTO, ErrorResponse>
}

final class DefaultTimetableService: TimetableService {
    
    private let networkService = NetworkService()
    
    func fetchDeptList() -> AnyPublisher<[DeptDTO], Error> {
        return request(.fetchDeptList)
    }
    
    func fetchFrame(semester: String) -> AnyPublisher<[FrameDTO], ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.fetchFrame(semester: semester))
            .catch { [weak self] error -> AnyPublisher<[FrameDTO], ErrorResponse> in
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
    
    func createFrame(semester: String) -> AnyPublisher<FrameDTO, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.createFrame(semester: semester))
            .catch { [weak self] error -> AnyPublisher<FrameDTO, ErrorResponse> in
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
    
    func modifyFrame(frame: FrameDTO) -> AnyPublisher<FrameDTO, ErrorResponse> {
        return networkService.requestWithResponse(api: TimetableAPI.modifyFrame(frame: frame))
            .catch { [weak self] error -> AnyPublisher<FrameDTO, ErrorResponse> in
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
