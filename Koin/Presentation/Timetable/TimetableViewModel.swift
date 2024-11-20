//
//  TimetableViewModel.swift
//  koin
//
//  Created by 김나훈 on 11/2/24.
//

import Combine

final class TimetableViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case fetchMySemester
        case modifyLecture(LectureData, Bool)
    }
    
    // MARK: - Output
    
    enum Output {
        case updateLectureList([SemesterLecture])
        case showingSelectedFrame(String, String?)
        case updateMyFrame([LectureData])
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let timetableRepository = DefaultTimetableRepository(service: DefaultTimetableService())
    
    // MARK: 강의정보
    private lazy var fetchLectureListUseCase = DefaultFetchLectureListUseCase(timetableRepository: timetableRepository)
    private lazy var modifyLectureUseCase = DefaultModifyLectureUseCase(timetableRepository: timetableRepository)
    private lazy var postLectureUseCase = DefaultPostLectureUseCase(timetableRepository: timetableRepository)
    private lazy var deleteLectureUseCase = DefaultDeleteLectureUseCase(timetableRepository: timetableRepository)
    
    // MARK: 프레임
    private lazy var fetchFrameUseCase = DefaultFetchFrameUseCase(timetableRepository: timetableRepository)
    private lazy var createFrameUseCase = DefaultCreateFrameUseCase(timetableRepository: timetableRepository)
    private lazy var deleteFrameUseCase = DefaultDeleteFrameUseCase(timetableRepository: timetableRepository)
    private lazy var modifyFrameUseCase = DefaultModifyFrameUseCase(timetableRepository: timetableRepository)
    
    // MARK: 기타
    private lazy var fetchMySemesterUseCase = DefaultFetchMySemesterUseCase(timetableRepository: timetableRepository)
    private lazy var fetchDeptListUseCase = DefaultFetchDeptListUseCase(timetableRepository: timetableRepository)
    private lazy var fetchLectureUseCase = DefaultFetchLectureUseCase(timetableRepository: timetableRepository)
    private lazy var fetchSemesterUseCase = DefaultFetchSemesterUseCase(timetableRepository: timetableRepository)
    
    
    
    
    private var selectedSemester: String? {
        didSet {
            fetchLectureList(semester: selectedSemester ?? "")
        }
    }
    private var selectedFrameId: Int? {
        didSet {
            fetchLecture(frameId: selectedFrameId ?? 0)
        }
    }
    private var lectureData: [LectureData] = [] {
        didSet {
            outputSubject.send(.updateMyFrame(lectureData))
        }
    }

    // MARK: - Initialization

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .fetchMySemester:
                self?.fetchMySemester()
            case let .modifyLecture(lecture, isAdd):
                self?.modifyLecture(lecture: lecture, isAdd: isAdd)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension TimetableViewModel {
    
    
    
    private func modifyLecture(lecture: LectureData, isAdd: Bool) {
        if isAdd {
            postLecture(lecture: lecture)
        } else {
            deleteLecture(lecture: lecture)
        }
    }
    
    private func postLecture(lecture: LectureData) {
        postLectureUseCase.execute(request: LectureRequest(timetableFrameID: selectedFrameId ?? 0, timetableLecture: [TimetableLecture(id: nil, lectureID: lecture.id, classTitle: lecture.name, classTime: lecture.classTime, classPlace: "", professor: lecture.professor, grades: lecture.grades, memo: "")])).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.lectureData = response
        }.store(in: &subscriptions)
    }
    
    private func deleteLecture(lecture: LectureData) {
        deleteLectureUseCase.execute(frameId: selectedFrameId ?? 0, lectureId: lecture.id).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] _ in
            self?.lectureData.removeAll { $0.classTime == lecture.classTime && $0.name == lecture.name }
        }.store(in: &subscriptions)

    }
    
    // 특정 프레임 id의 모든 강의 조회
    private func fetchLecture(frameId: Int) {
        fetchLectureUseCase.execute(frameId: frameId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.lectureData = response
        }.store(in: &subscriptions)

    }
    
    // 해당 학기 모든 프레임 조회 ( 처음에 보여줄 학기 시간표 선택 위해 필요 )
    private func fetchFrame(semester: String) {
        fetchFrameUseCase.execute(semester: semester).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response  in
            if let firstMainFrame = response.first(where: { $0.isMain }) {
                self?.selectedFrameId = firstMainFrame.id
                self?.outputSubject.send(.showingSelectedFrame(semester, firstMainFrame.timetableName))
            } else {
                self?.outputSubject.send(.showingSelectedFrame("학기 추가하기", nil))
            }
        }.store(in: &subscriptions)

    }
    
    // 나의 모든 학기 조회 ( 처음에 보여줄 학기들 리스트 보여주기 위해 필요 )
    private func fetchMySemester() {
        fetchMySemesterUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }receiveValue: { [weak self] response in
            if let lastSemester = response.semesters.first {
                self?.selectedSemester = lastSemester
                self?.fetchFrame(semester: lastSemester)
            } else {
                self?.outputSubject.send(.showingSelectedFrame("학기 추가하기", nil))
            }
        }.store(in: &subscriptions)

    }
    private func fetchLectureList(semester: String) {
        fetchLectureListUseCase.execute(semester: semester).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateLectureList(response))
        }.store(in: &subscriptions)

    }
    
}
