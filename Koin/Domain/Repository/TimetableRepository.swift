//
//  TimetableRepository.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Combine

protocol TimetableRepository {
    func fetchDeptList() -> AnyPublisher<[DeptDTO], Error>
    func fetchFrame(semester: String) -> AnyPublisher<[FrameDTO], ErrorResponse>
    func deleteFrame(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func createFrame(semester: String) -> AnyPublisher<FrameDTO, ErrorResponse>
    func modifyFrame(frame: FrameDTO) -> AnyPublisher<FrameDTO, ErrorResponse>
}
