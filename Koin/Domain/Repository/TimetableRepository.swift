//
//  TimetableRepository.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Combine

protocol TimetableRepository {
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
    func deleteLecture(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func rollbackFrame(id: Int) -> AnyPublisher<LectureDto, ErrorResponse>
    func fetchAllFrames() -> AnyPublisher<SemestersDto, ErrorResponse>
}
