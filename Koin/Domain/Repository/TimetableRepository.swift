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
    func fetchLecture(frameId: Int) -> AnyPublisher<LectureDTO, ErrorResponse>
    func modifyLecture(request: LectureRequest) -> AnyPublisher<LectureDTO, ErrorResponse>
    func postLecture(request: LectureRequest) -> AnyPublisher<LectureDTO, ErrorResponse>
    func fetchMySemester() -> AnyPublisher<MySemesterDTO, ErrorResponse>
    func fetchLectureList(semester: String) -> AnyPublisher<[SemesterLecture], Error>
    func fetchSemester() -> AnyPublisher<[SemesterDTO], Error>
    func deleteLecture(frameId: Int, lectureId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteSemester(semester: String) -> AnyPublisher<Void, ErrorResponse>
}
