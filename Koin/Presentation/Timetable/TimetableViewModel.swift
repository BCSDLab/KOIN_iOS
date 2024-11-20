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
        case fetchLectureList
        case fetchMySemester
    }
    
    // MARK: - Output
    
    enum Output {
        case updateLectureList([SemesterLecture])
        case showingSelectedFrame(String, String?)
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
            
        }
    }

    // MARK: - Initialization

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .fetchLectureList:
                self?.fetchLectureList(semester: "20241")
            case .fetchMySemester:
                self?.fetchMySemester()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension TimetableViewModel {
    
    private func fetchFrame(semester: String) {
        fetchFrameUseCase.execute(semester: semester).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response  in
            if let firstMainFrame = response.first(where: { $0.isMain }) {
                self?.outputSubject.send(.showingSelectedFrame(semester, firstMainFrame.timetableName))
            } else {
                self?.outputSubject.send(.showingSelectedFrame("학기 추가하기", nil))
            }
        }.store(in: &subscriptions)

    }
    
    private func fetchMySemester() {
        fetchMySemesterUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }receiveValue: { [weak self] response in
            if let lastSemester = response.semesters.last {
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
