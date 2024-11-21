//
//  TimetableViewModel.swift
//  koin
//
//  Created by 김나훈 on 11/2/24.
//

import Combine

struct FrameData {
    let semester: String
    var frame: [FrameDTO]
}

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
    
    enum NextInput {
        case fetchFrameList
        case createFrame(String)
        case deleteFrame(FrameDTO)
        case modifyFrame(FrameDTO)
    }
    enum NextOutput {
        case reloadData
        case showToast(String)
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
                self?.fetchMySemester()
            case let .modifyLecture(lecture, isAdd):
                self?.modifyLecture(lecture: lecture, isAdd: isAdd)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    func transform(with input: AnyPublisher<NextInput, Never>) -> AnyPublisher<NextOutput, Never> {
        input.sink { [weak self] input in
            switch input {
            case .fetchFrameList:
                self?.fetchMySemesters()
            case .createFrame(let semester):
                self?.createFrame(semester: semester)
            case .deleteFrame(let frame):
                self?.deleteFrame(frame: frame)
            case .modifyFrame(let frame):
                self?.modifyFrame(frame: frame)
            }
        }.store(in: &subscriptions)
        return nextOutputSubject.eraseToAnyPublisher()
    }
}

extension TimetableViewModel {
    
    private func modifyFrame(frame: FrameDTO) {
        
        modifyFrameUseCase.execute(frame: frame).sink { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.nextOutputSubject.send(.showToast(error.message))
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            for (index, frameData) in self.frameData.enumerated() {
                if let frameIndex = frameData.frame.firstIndex(where: { $0.id == frame.id }) {
                    self.frameData[index].frame[frameIndex] = frame
                    if frame.isMain {
                        self.frameData[index].frame = self.frameData[index].frame.map { existingFrame in
                            var updatedFrame = existingFrame
                            updatedFrame.isMain = (existingFrame.id == frame.id) // 현재 프레임만 true
                            return updatedFrame
                        }
                    }
                    break // 찾았으면 루프 종료
                }
            }
        }.store(in: &subscriptions)
        
    }
    private func deleteFrame(frame: FrameDTO) {
        deleteFrameUseCase.execute(id: frame.id).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] in
            guard let self = self else { return }
            
            // `frameData`에서 해당 프레임 삭제
            for (index, frameData) in self.frameData.enumerated() {
                if let frameIndex = frameData.frame.firstIndex(where: { $0.id == frame.id }) {
                    self.frameData[index].frame.remove(at: frameIndex)
                    
                    // `frameData`에서 학기가 빈 경우 제거 (선택사항)
                    if self.frameData[index].frame.isEmpty {
                        self.frameData.remove(at: index)
                    }
                    
                    break // 찾았으면 루프 종료
                }
            }
        }.store(in: &subscriptions)
        
    }
    private func createFrame(semester: String) {
        createFrameUseCase.execute(semester: semester).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            
            // `frameData`에서 해당 `semester`를 찾음
            if let index = self.frameData.firstIndex(where: { $0.semester == semester }) {
                // `frameData`의 해당 `semester` 배열의 마지막에 `response` 추가
                self.frameData[index].frame.append(response)
            } else {
                // `frameData`에 `semester`가 없으면 새로 추가
                self.frameData.append(FrameData(semester: semester, frame: [response]))
            }
        }.store(in: &subscriptions)
        
    }
    
    private func fetchMySemesters() {
        
        fetchMySemesterUseCase.execute()
            .flatMap { [weak self] response -> AnyPublisher<[FrameData], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                let semesters = response.semesters
                return semesters.publisher // 배열을 퍼블리셔로 변환
                    .flatMap { semester -> AnyPublisher<FrameData, Never> in
                        self.fetchFrame(for: semester)
                    }
                    .collect() // 모든 FrameData를 하나의 배열로 수집
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("Failed fetching semesters: \(error)")
                }
            }, receiveValue: { [weak self] fetchedFrames in
                self?.frameData = fetchedFrames
                Log.make().info("FrameData updated: \(fetchedFrames)")
            })
            .store(in: &subscriptions)
    }
    
    private func fetchFrame(for semester: String) -> AnyPublisher<FrameData, Never> {
        fetchFrameUseCase.execute(semester: semester)
            .map { frames -> FrameData in
                // FrameDTO를 기반으로 FrameData 생성
                return FrameData(semester: semester, frame: frames)
            }
            .catch { error -> Just<FrameData> in
                Log.make().error("Failed fetching frames for semester \(semester): \(error)")
                return Just(FrameData(semester: semester, frame: [])) // 실패 시 빈 데이터 반환
            }
            .eraseToAnyPublisher()
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
