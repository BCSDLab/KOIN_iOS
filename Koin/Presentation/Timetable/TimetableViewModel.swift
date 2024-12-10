//
//  TimetableViewModel.swift
//  koin
//
//  Created by 김나훈 on 11/2/24.
//

import Combine
import Foundation

struct FrameData {
    let semester: String
    var frame: [FrameDTO]
}

final class TimetableViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case fetchMySemester
        case modifyLecture(LectureData, Bool)
        case _deleteLecture(LectureData)
        case postCustomLecture(String, [Int])
    }
    
    // MARK: - Output
    
    enum Output {
        case updateLectureList([SemesterLecture])
        case showingSelectedFrame(String, String?)
        case updateMyFrame([LectureData])
    }
    
    enum NextInput {
        case fetchFrameList
        case createFrame(String)
        case deleteFrame(FrameDTO)
        case modifyFrame(FrameDTO)
        case modifySemester([String], [String])
        case rollbackFrame(Int)
    }
    enum NextOutput {
        case reloadData
        case showToast(String)
        case showToastWithId(String, Int)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let nextOutputSubject = PassthroughSubject<NextOutput, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let timetableRepository = DefaultTimetableRepository(service: DefaultTimetableService())
    
    // MARK: 강의정보
    private lazy var fetchLectureListUseCase = DefaultFetchLectureListUseCase(timetableRepository: timetableRepository)
    private lazy var modifyLectureUseCase = DefaultModifyLectureUseCase(timetableRepository: timetableRepository)
    private lazy var postLectureUseCase = DefaultPostLectureUseCase(timetableRepository: timetableRepository)
    private lazy var deleteLectureUseCase = DefaultDeleteLectureUseCase(timetableRepository: timetableRepository)
    private lazy var deleteLecturByIdUseCase = _DefaultDeleteLectureUseCase(timetableRepository: timetableRepository)
    
    // MARK: 프레임
    private lazy var fetchFrameUseCase = DefaultFetchFrameUseCase(timetableRepository: timetableRepository)
    private lazy var createFrameUseCase = DefaultCreateFrameUseCase(timetableRepository: timetableRepository)
    private lazy var deleteFrameUseCase = DefaultDeleteFrameUseCase(timetableRepository: timetableRepository)
    private lazy var modifyFrameUseCase = DefaultModifyFrameUseCase(timetableRepository: timetableRepository)
    private lazy var deleteSemesterUseCase = DefaultDeleteSemesterUseCase(timetableRepository: timetableRepository)
    private lazy var rollbackFrameUseCase = DefaultRollbackFrameUseCase(timetableRepository: timetableRepository)
    private lazy var fetchFramesUseCase = DefaultFetchFramesUseCase(timetableRepository: timetableRepository)
    
    
    // MARK: 기타
    private lazy var fetchMySemesterUseCase = DefaultFetchMySemesterUseCase(timetableRepository: timetableRepository)
    private lazy var fetchDeptListUseCase = DefaultFetchDeptListUseCase(timetableRepository: timetableRepository)
    private lazy var fetchLectureUseCase = DefaultFetchLectureUseCase(timetableRepository: timetableRepository)
    private lazy var fetchSemesterUseCase = DefaultFetchSemesterUseCase(timetableRepository: timetableRepository)
    
    // 현재 선택된 학기
    var selectedSemester: String? {
        didSet {
            fetchLectureList(semester: selectedSemester ?? "")
        }
    }
    
    // 현재보여주고 있는 프레임
    var selectedFrameId: Int? {
        didSet {
            fetchLecture(frameId: selectedFrameId ?? 0)
        }
    }
    
    // 현재 보여주고있는 시간표 리스트
    private var lectureData: [LectureData] = [] {
        didSet {
            outputSubject.send(.updateMyFrame(lectureData))
        }
    }
    
    // 전체 프레임 리스트
    private(set) var frameData: [FrameData] = [] {
        didSet {
            nextOutputSubject.send(.reloadData)
        }
    }
    
    
    // MARK: - Initialization
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        
        input.sink { [weak self] input in
            switch input {
            case .fetchMySemester:
                self?.fetchMyFrames()
            case let .modifyLecture(lecture, isAdd):
                self?.modifyLecture(lecture: lecture, isAdd: isAdd)
            case ._deleteLecture(let lecture):
                self?.deleteLectureById(lecture: lecture)
            case let .postCustomLecture(lectureName, lectureTime):
                self?.postCustomLecture(lectureName: lectureName, classTime: lectureTime)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    func transform(with input: AnyPublisher<NextInput, Never>) -> AnyPublisher<NextOutput, Never> {
        input.sink { [weak self] input in
            switch input {
            case .fetchFrameList:
                self?.fetchFrames()
            case .createFrame(let semester):
                self?.createFrame(semester: semester)
            case .deleteFrame(let frame):
                self?.deleteFrame(frame: frame)
            case .modifyFrame(let frame):
                self?.modifyFrame(frame: frame)
            case let .modifySemester(addedSemester, removedSemester):
                addedSemester.forEach {
                    self?.createFrame(semester: $0)
                }
                removedSemester.forEach {
                    self?.deleteSemester(semester: $0)
                }
            case .rollbackFrame(let id):
                self?.rollbackFrame(id: id)
            }
        }.store(in: &subscriptions)
        return nextOutputSubject.eraseToAnyPublisher()
    }
}

extension TimetableViewModel {
    
    func checkDuplicatedClassTime(classTime: [Int]) -> Bool {
        for lecture in lectureData {
            // 겹치는 시간이 있으면 true 반환
            if !Set(lecture.classTime).isDisjoint(with: classTime) {
                return true
            }
        }
        return false
    }
    
    
    private func deleteLectureById(lecture: LectureData) {
        
        deleteLecturByIdUseCase.execute(id: lecture.id).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] _ in
            self?.lectureData.removeAll { $0.classTime == lecture.classTime && $0.name == lecture.name && $0.professor == lecture.professor}
        }.store(in: &subscriptions)
        
    }
    
    private func _deleteLecture(_ lecture: LectureData) {
        deleteLectureUseCase.execute(frameId: selectedFrameId ?? 0, lectureId: lecture.id) .sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] _ in
            
            self?.lectureData.removeAll { $0.classTime == lecture.classTime && $0.name == lecture.name && $0.professor == $0.professor}
        }.store(in: &subscriptions)
    }
    
    private func fetchFrames() {
        fetchFramesUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.frameData = response
        }.store(in: &subscriptions)

    }
}

extension TimetableViewModel {
    
    private func modifyLecture(lecture: LectureData, isAdd: Bool) {
        if isAdd {
            postLecture(lecture: lecture)
        } else {
            _deleteLecture(lecture)
        }
    }
    
    private func postCustomLecture(lectureName: String, classTime: [Int]) {
        let request = LectureRequest(timetableFrameID: selectedFrameId ?? 0, timetableLecture: [TimetableLecture(lectureID: nil, classTitle: lectureName, classInfos: [ClassInfo(classTime: classTime, classPlace: "")], professor: "", grades: "0", memo: "no memo")])
        postLectureUseCase.execute(request: request).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.lectureData = response
        }.store(in: &subscriptions)
    }
    
    private func postLecture(lecture: LectureData) {
        let lectureRequest = LectureRequest(timetableFrameID: selectedFrameId ?? 0, timetableLecture: [TimetableLecture(lectureID: lecture.id, classTitle: lecture.name, classInfos: [ ClassInfo( classTime: lecture.classTime, classPlace: "")], professor: lecture.professor, grades: lecture.grades, memo: "메모메모")])
        
        postLectureUseCase.execute(request: lectureRequest).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.lectureData = response
        }.store(in: &subscriptions)
    }
    
    // 특정 프레임 id의 모든 강의 조회
    private func fetchLecture(frameId: Int) {
        fetchLectureUseCase.execute(frameId: frameId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            self.lectureData = response
            
            for frameData in self.frameData {
                for frame in frameData.frame {
                    if frame.id == frameId {
                        self.outputSubject.send(.showingSelectedFrame(frameData.semester, frame.timetableName))
                    }
                }
            }
        }.store(in: &subscriptions)
        
    }
    
    // 해당 학기 모든 프레임 조회 ( 처음에 보여줄 학기 시간표 선택 위해 필요 )
    private func fetchFrame(semester: String) {
        fetchFrameUseCase.execute(semester: semester).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response  in
            if let firstMainFrame = response.first(where: { $0.isMain }) ?? response.first {
                self?.selectedFrameId = firstMainFrame.id
                self?.outputSubject.send(.showingSelectedFrame(semester, firstMainFrame.timetableName))
            } else {
                self?.outputSubject.send(.showingSelectedFrame("학기 추가하기", nil))
            }
        }.store(in: &subscriptions)
        
    }
    
    private func fetchMyFrames() {
        fetchFramesUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            
            if let lastSemester = response.first?.semester {
                self?.selectedSemester = lastSemester
                self?.fetchFrame(semester: lastSemester)
            } else {
                self?.outputSubject.send(.showingSelectedFrame("학기 추가하기", nil))
            }
        }.store(in: &subscriptions)
    }
    
    // 해당 학기 강의들 조회
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

// FrameList
extension TimetableViewModel {
    
    private func rollbackFrame(id: Int) {
        rollbackFrameUseCase.execute(id: id).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.fetchFrames()
        }.store(in: &subscriptions)
    }
    
    // 프레임 1개 삭제
    private func deleteFrame(frame: FrameDTO) {
        deleteFrameUseCase.execute(id: frame.id).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.nextOutputSubject.send(.showToast(error.message))
            }
        } receiveValue: { [weak self] in
            self?.fetchFrames()
            self?.nextOutputSubject.send(.showToastWithId(frame.timetableName, frame.id))
            if frame.id == self?.selectedFrameId {
                self?.fetchMyFrames()
            }
        }.store(in: &subscriptions)
    }
    
    private func modifyFrame(frame: FrameDTO) {
        modifyFrameUseCase.execute(frame: frame).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.nextOutputSubject.send(.showToast(error.message))
            }
        } receiveValue: { [weak self] response in
            self?.fetchFrames()
        }.store(in: &subscriptions)
    }
    
    // 프레임 추가하기
    private func createFrame(semester: String) {
        createFrameUseCase.execute(semester: semester).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.nextOutputSubject.send(.showToast(error.message))
            }
        } receiveValue: { [weak self] response in
            self?.fetchFrames()
        }.store(in: &subscriptions)
    }
    
    // 해당 학기 삭제하기
    private func deleteSemester(semester: String) {
        deleteSemesterUseCase.execute(semester: semester).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] _ in
            self?.fetchFrames()
            if semester == self?.selectedSemester {
                self?.fetchMyFrames()
            }
        }.store(in: &subscriptions)
        
    }
}
