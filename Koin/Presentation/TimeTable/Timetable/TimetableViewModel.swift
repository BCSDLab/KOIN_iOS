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
    var frame: [FrameDto]
}

final class TimetableViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case fetchMySemester
        case modifyLecture(LectureData, Bool)
        case _deleteLecture(LectureData)
        case saveCustomLecture(TimetableLecture)
        
        case selectedDepartment(String?)
    }
    
    // MARK: - Output
    
    enum Output {
        case updateLectureList([SemesterLecture])
        case showingSelectedFrame(String, String?)
        case updateMyFrame([LectureData])
        case showToast(String, intent: ToastIntent = .neutral)
    }
    
    enum NextInput {
        case fetchFrameList
        case createFrame(String)
        case deleteFrame(FrameDto)
        case modifyFrame(FrameDto)
        case modifySemester([String], [String])
        case fetchSemesters
    }
    enum NextOutput {
        case reloadData
        case showToast(String, intent: ToastIntent = .neutral)
        case showSemesterModal([String])
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let nextOutputSubject = PassthroughSubject<NextOutput, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var dataSubscriptions: Set<AnyCancellable> = []
    private var loadedUserId: Int?
    /// 서버 학기 목록(/semesters). 오래된 학기부터 정렬한다. 미리보기 학기와 학기 추가 모달이 같이 쓴다.
    private var semesters: [String] = []
    /// 학생만 시간표 기능을 쓴다. 비로그인·일반 유저는 미리보기만 본다.
    @Published private(set) var canUseStudentFeatures = UserDataManager.shared.isStudent
    @Published private(set) var hasLoadedFrames = false
    /// 진행 중인 추가·삭제·수정 요청이 있는지. 화면은 이 값으로 로딩 표시를 한다. 조회(GET)는 세지 않는다.
    @Published private(set) var isLoading = false
    private var loadingCount = 0 {
        didSet { isLoading = loadingCount > 0 }
    }
    /// 진입 화면이 이미 받은 메인 시간표. 서버 응답 전까지 그리드와 제목을 먼저 보여 준다.
    let initialFrame: MainTimetableFrame?

    var previewFrameData: [FrameData] {
        let started = startedPreviewSemesters
        let semesters = started.isEmpty ? [Self.fallbackSemester()] : Array(started.suffix(5).reversed())
        return semesters.enumerated().map { index, semester in
            FrameData(semester: semester, frame: [FrameDto(id: -(index + 1), timetableName: "시간표1", isMain: false)])
        }
    }

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
    private lazy var fetchFramesUseCase = DefaultFetchFramesUseCase(timetableRepository: timetableRepository)
    
    
    // MARK: 기타
    private lazy var fetchMySemesterUseCase = DefaultFetchMySemesterUseCase(timetableRepository: timetableRepository)
    private lazy var fetchDeptListUseCase = DefaultFetchDeptListUseCase(timetableRepository: timetableRepository)
    private lazy var fetchLectureUseCase = DefaultFetchLectureUseCase(timetableRepository: timetableRepository)
    private lazy var fetchSemesterUseCase = DefaultFetchSemesterUseCase(timetableRepository: timetableRepository)
    
    // 현재 선택된 학기
    var selectedSemester: String? {
        didSet {
            guard canUseStudentFeatures, let selectedSemester else { return }
            fetchLectureList(semester: selectedSemester)
        }
    }
    
    // 현재보여주고 있는 프레임
    var selectedFrameId: Int? {
        didSet {
            guard canUseStudentFeatures, let selectedFrameId, selectedFrameId > 0 else { return }
            fetchLecture(frameId: selectedFrameId)
        }
    }
    
    // 현재 보여주고있는 시간표 리스트
    private(set) var lectureData: [LectureData] = [] {
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
    
    // 전체 전공 목록
    private(set) var departments: [String] = []
    private(set) var selectedDepartment: String?
    
    
    // MARK: - Initialization
    
    init(initialFrame: MainTimetableFrame? = nil) {
        self.initialFrame = initialFrame
        if let initialFrame {
            lectureData = initialFrame.lectures
            // 같은 사용자로 학생 확인이 끝나면 주입한 강의를 지우지 않고 서버 값으로 교체한다.
            loadedUserId = UserDataManager.shared.id
        }
    }

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        
        input.sink { [weak self] input in
            switch input {
            case .fetchMySemester:
                self?.refreshAccess(forFrameList: false)
            case let .modifyLecture(lecture, isAdd):
                self?.modifyLecture(lecture: lecture, isAdd: isAdd)
            case ._deleteLecture(let lecture):
                self?.deleteLectureById(lecture: lecture)
            case let .saveCustomLecture(request):
                self?.saveCustomLecture(request)
            case let .selectedDepartment(selectedDepartment):
                self?.selectedDepartment = selectedDepartment
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    func transform(with input: AnyPublisher<NextInput, Never>) -> AnyPublisher<NextOutput, Never> {
        // 입력 구독도 반환 publisher에 포함해 목록 화면의 구독 해제 시 함께 해제한다.
        let actions = input.flatMap { [weak self] input -> Empty<NextOutput, Never> in
            switch input {
            case .fetchFrameList:
                self?.refreshAccess(forFrameList: true)
            case .createFrame(let semester):
                self?.createFrame(semester: semester, message: "시간표를 추가했어요")
            case .deleteFrame(let frame):
                self?.deleteFrame(frame: frame)
            case .modifyFrame(let frame):
                self?.modifyFrame(frame: frame)
            case let .modifySemester(addedSemester, removedSemester):
                // 성공마다 토스트를 보내도 이전 토스트가 교체되어 화면에는 하나만 남는다.
                addedSemester.forEach {
                    self?.createFrame(semester: $0, message: "학기를 추가했어요")
                }
                removedSemester.forEach {
                    self?.deleteSemester(semester: $0)
                }
            case .fetchSemesters:
                self?.fetchSemesters(showsModal: true)
            }
            return Empty()
        }
        return nextOutputSubject.merge(with: actions).eraseToAnyPublisher()
    }
}

extension TimetableViewModel {
    
    func performLectureModification(lectureData: LectureData) -> AnyPublisher<Void, Never> {
        guard canUseStudentFeatures else { return Empty().eraseToAnyPublisher() }
        let deleteDuplicatesPublisher = Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            let duplicatedLectures = self.lectureData.filter { existingLecture in
                existingLecture.classTime.contains { lectureData.classTime.contains($0) }
            }
            let deletePublishers = duplicatedLectures.map { lecture in
                Future<Void, Never> { promise in
                    self.tracked(self.deleteLecturByIdUseCase.execute(id: lecture.id)).sink(
                        receiveCompletion: { _ in promise(.success(())) },
                        receiveValue: { _ in }
                    ).store(in: &self.dataSubscriptions)
                }
            }
            Publishers.MergeMany(deletePublishers)
                .collect()
                .sink(receiveCompletion: { _ in promise(.success(())) },
                      receiveValue: { _ in })
                .store(in: &self.dataSubscriptions)
        }
        // Deferred: 겹치는 강의 삭제가 끝난 뒤에 추가 요청을 보낸다. Future는 생성 즉시 실행된다.
        let modifyPublisher = Deferred { Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            self.tracked(self.postLectureUseCase.execute(request: self.regularLectureRequest(lectureData))).sink(
                receiveCompletion: { _ in promise(.success(())) },
                receiveValue: { [weak self] _ in
                    self?.lectureData.append(lectureData)
                    self?.outputSubject.send(.showToast("일정을 추가했어요"))
                }
            ).store(in: &self.dataSubscriptions)
        } }
        return deleteDuplicatesPublisher
            .flatMap { modifyPublisher }
            .eraseToAnyPublisher()
    }
    func checkDuplicatedClassTime(classTime: [Int]) -> Bool {
        for lecture in lectureData {
            // 겹치는 시간이 있으면 true 반환
            if !Set(lecture.classTime).isDisjoint(with: classTime) {
                return true
            }
        }
        return false
    }

    /// 직접 일정과 시간이 겹치는 강의. 수정 중인 일정 자신은 제외한다.
    func conflictingLecture(with lecture: TimetableLecture) -> LectureData? {
        let classTimes = Set(lecture.classInfos.flatMap { $0.classTime ?? [] })
        return lectureData.first { $0.id != lecture.id && !classTimes.isDisjoint(with: $0.classTime) }
    }
    
    
    private func deleteLectureById(lecture: LectureData) {
        guard canUseStudentFeatures else { return }
        tracked(deleteLecturByIdUseCase.execute(id: lecture.id)).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.outputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] _ in
                guard let self else { return }
                self.lectureData.removeAll { $0.id == lecture.id }
                self.outputSubject.send(.showToast("일정을 삭제했어요"))
            }
        ).store(in: &dataSubscriptions)
    }

    private func _deleteLecture(_ lecture: LectureData) {
        guard canUseStudentFeatures else { return }
        tracked(deleteLectureUseCase.execute(frameId: selectedFrameId ?? 0, lectureId: lecture.id)).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.outputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] _ in
                guard let self else { return }
                self.lectureData.removeAll {
                    Set($0.classTime) == Set(lecture.classTime) &&
                    $0.name == lecture.name &&
                    $0.professor == lecture.professor
                }
                self.outputSubject.send(.showToast("일정을 삭제했어요"))
            }
        ).store(in: &dataSubscriptions)
    }

    private func fetchFrames() {
        guard canUseStudentFeatures else { return }
        fetchFramesUseCase.execute().sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.hasLoadedFrames = true
                    self?.nextOutputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] response in
                self?.hasLoadedFrames = true
                self?.frameData = response
            }
        ).store(in: &dataSubscriptions)
    }
}

extension TimetableViewModel {
    
    private func modifyLecture(lecture: LectureData, isAdd: Bool) {
        guard canUseStudentFeatures else { return }
        if isAdd {
            postLecture(lecture: lecture)
        } else {
            _deleteLecture(lecture)
        }
    }
    
    private func saveCustomLecture(_ lecture: TimetableLecture) {
        guard canUseStudentFeatures, let frameId = selectedFrameId, frameId > 0 else {
            outputSubject.send(.showToast("일정을 저장하지 못했어요", intent: .negative))
            return
        }
        let request = LectureRequest(timetableFrameID: frameId, timetableLecture: [lecture])
        let isEditing = lecture.id != nil
        let publisher: AnyPublisher<[LectureData], ErrorResponse>
        if isEditing {
            publisher = modifyLectureUseCase.execute(request: request).map { $0.toDomain() }.eraseToAnyPublisher()
        } else {
            publisher = postLectureUseCase.execute(request: request)
        }
        tracked(publisher).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.outputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] lectures in
                self?.lectureData = lectures
                self?.outputSubject.send(.showToast(isEditing ? "일정을 수정했어요" : "일정을 추가했어요"))
            }
        ).store(in: &dataSubscriptions)
    }

    private func regularLectureRequest(_ lecture: LectureData) -> LectureRequest {
        LectureRequest(timetableFrameID: selectedFrameId ?? 0, timetableLecture: [TimetableLecture(lectureID: lecture.id, classTitle: lecture.name, classInfos: [ClassInfo(classTime: lecture.classTime, classPlace: "")], professor: lecture.professor, grades: lecture.grades, memo: "메모메모")])
    }

    private func postLecture(lecture: LectureData) {
        guard canUseStudentFeatures else { return }
        tracked(postLectureUseCase.execute(request: regularLectureRequest(lecture))).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.outputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] response in
                self?.lectureData = response
                self?.outputSubject.send(.showToast("일정을 추가했어요"))
            }
        ).store(in: &dataSubscriptions)
    }
    
    // 특정 프레임 id의 모든 강의 조회
    private func fetchLecture(frameId: Int) {
        guard canUseStudentFeatures else { return }
        fetchLectureUseCase.execute(frameId: frameId).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.lectureData = response
                
                for frameData in self.frameData {
                    for frame in frameData.frame {
                        if frame.id == frameId {
                            self.outputSubject.send(.showingSelectedFrame(frameData.semester, frame.timetableName))
                        }
                    }
                }
            }
        ).store(in: &dataSubscriptions)
    }
    
    // 해당 학기 모든 프레임 조회 ( 처음에 보여줄 학기 시간표 선택 위해 필요 )
    private func fetchFrame(semester: String) {
        guard canUseStudentFeatures else { return }
        fetchFrameUseCase.execute(semester: semester).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response  in
                if let firstMainFrame = response.first(where: { $0.isMain }) ?? response.first {
                    self?.selectedFrameId = firstMainFrame.id
                    self?.outputSubject.send(.showingSelectedFrame(semester, firstMainFrame.timetableName))
                } else {
                    self?.lectureData = []
                    self?.outputSubject.send(.showingSelectedFrame("학기 추가하기", nil))
                }
            }
        ).store(in: &dataSubscriptions)
    }
    
    private func fetchMyFrames() {
        guard canUseStudentFeatures else { return }
        fetchFramesUseCase.execute().sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.hasLoadedFrames = true
                    self?.nextOutputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] response in
                self?.hasLoadedFrames = true
                self?.frameData = response
                if let lastSemester = response.first?.semester {
                    self?.selectedSemester = lastSemester
                    self?.fetchFrame(semester: lastSemester)
                } else {
                    self?.lectureData = []
                    self?.outputSubject.send(.showingSelectedFrame("학기 추가하기", nil))
                }
            }
        ).store(in: &dataSubscriptions)
    }
    
    // 해당 학기 강의들 조회
    private func fetchLectureList(semester: String) {
        guard canUseStudentFeatures else { return }
        fetchLectureListUseCase.execute(semester: semester).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.outputSubject.send(.updateLectureList(response))
                self?.updateDeparments(response)
            }
        ).store(in: &dataSubscriptions)
    }
}

// FrameList
extension TimetableViewModel {
    
    // 프레임 1개 삭제
    private func deleteFrame(frame: FrameDto) {
        guard canUseStudentFeatures else { return }
        tracked(deleteFrameUseCase.execute(id: frame.id)).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.nextOutputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] in
                self?.fetchFrames()
                self?.nextOutputSubject.send(.showToast("시간표를 삭제했어요"))
                if frame.id == self?.selectedFrameId {
                    self?.fetchMyFrames()
                }
            }
        ).store(in: &dataSubscriptions)
    }
    
    private func modifyFrame(frame: FrameDto) {
        guard canUseStudentFeatures else { return }
        tracked(modifyFrameUseCase.execute(frame: frame)).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.nextOutputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] response in
                self?.fetchFrames()
                self?.nextOutputSubject.send(.showToast("시간표를 수정했어요"))
            }
        ).store(in: &dataSubscriptions)
    }
    
    // 프레임 추가하기
    private func createFrame(semester: String, message: String) {
        guard canUseStudentFeatures else { return }
        tracked(createFrameUseCase.execute(semester: semester)).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.nextOutputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] response in
                self?.fetchFrames()
                self?.nextOutputSubject.send(.showToast(message))
            }
        ).store(in: &dataSubscriptions)
    }
    
    // 해당 학기 삭제하기
    private func deleteSemester(semester: String) {
        guard canUseStudentFeatures else { return }
        tracked(deleteSemesterUseCase.execute(semester: semester)).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.nextOutputSubject.send(.showToast(error.message, intent: .negative))
                }
            },
            receiveValue: { [weak self] _ in
                self?.fetchFrames()
                self?.nextOutputSubject.send(.showToast("학기를 삭제했어요"))
                if semester == self?.selectedSemester {
                    self?.fetchMyFrames()
                }
            }
        ).store(in: &dataSubscriptions)
    }
}

extension TimetableViewModel {
    private func updateDeparments(_ response: [SemesterLecture]) {
        self.departments = response
            .map(\.department)
            .reduce(into: Set<String>(), { departments, department in
                departments.insert(department)
            })
            .sorted()
        self.selectedDepartment = nil
    }
}


extension TimetableViewModel {
    /// 쓰기 요청 수를 세어 로딩 표시를 갱신한다. 이벤트는 main에서 받는다.
    private func tracked<P: Publisher>(_ publisher: P) -> AnyPublisher<P.Output, P.Failure> {
        publisher
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.loadingCount += 1 },
                receiveCompletion: { [weak self] _ in self?.loadingCount -= 1 },
                receiveCancel: { [weak self] in self?.loadingCount -= 1 }
            )
            .eraseToAnyPublisher()
    }

    private func refreshAccess(forFrameList: Bool) {
        let isStudent = UserDataManager.shared.isStudent
        let userId = UserDataManager.shared.id
        if !isStudent || loadedUserId != userId {
            clearProtectedData()
        }
        canUseStudentFeatures = isStudent
        if isStudent {
            loadedUserId = userId
            if forFrameList {
                fetchFrames()
                fetchSemesters()
            } else if let frameId = selectedFrameId, let semester = selectedSemester {
                fetchLectureList(semester: semester)
                fetchLecture(frameId: frameId)
            } else {
                fetchMyFrames()
            }
        } else {
            publishPreview()
            fetchSemesters()
        }
    }

    private func clearProtectedData() {
        selectedSemester = nil
        selectedFrameId = nil
        lectureData = []
        hasLoadedFrames = false
        frameData = []
        departments = []
        selectedDepartment = nil
        loadedUserId = nil
        outputSubject.send(.updateLectureList([]))
        outputSubject.send(.showingSelectedFrame(previewSemester, "시간표1"))
    }

    /// 오늘 날짜 기준 학기(3~6월 1학기, 7~8월 여름, 9~12월 2학기, 1~2월 전년도 겨울)까지만 쓴다.
    /// 미리 등록된 다음 학기(예: 11월의 겨울학기)는 제외한다.
    private var startedPreviewSemesters: [String] {
        let currentOrder = Self.semesterOrder(Self.fallbackSemester())
        return semesters.filter { Self.semesterOrder($0) <= currentOrder }
    }

    private var previewSemester: String {
        startedPreviewSemesters.last ?? Self.fallbackSemester()
    }

    private func publishPreview() {
        let semester = previewSemester
        outputSubject.send(.showingSelectedFrame(semester, "시간표1"))
        nextOutputSubject.send(.reloadData)
    }

    /// 학기 목록을 받는다. 이미 받았으면 다시 요청하지 않는다.
    /// - Parameter showsModal: 학기 추가 버튼에서 불렀을 때 true. 목록을 받으면 모달을 띄우고, 실패하면 에러 토스트를 보낸다.
    private func fetchSemesters(showsModal: Bool = false) {
        guard semesters.isEmpty else {
            if showsModal { nextOutputSubject.send(.showSemesterModal(semesters)) }
            return
        }
        fetchSemesterUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if showsModal, case let .failure(error) = completion {
                    self?.nextOutputSubject.send(.showToast(error.message, intent: .negative))
                }
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                self.semesters = Array(Set(response.map(\.semester)))
                    .filter { !$0.reverseFormatSemester().isEmpty }
                    .sorted { Self.semesterOrder($0) < Self.semesterOrder($1) }
                if !self.canUseStudentFeatures { self.publishPreview() }
                if showsModal { self.nextOutputSubject.send(.showSemesterModal(self.semesters)) }
            })
            .store(in: &dataSubscriptions)
    }

    private static func semesterOrder(_ semester: String) -> Int {
        let year = Int(semester.prefix(4)) ?? 0
        let term: Int
        if semester.contains("겨울") || semester.hasSuffix("4") { term = 4 }
        else if semester.contains("여름") || semester.hasSuffix("3") { term = 2 }
        else if semester.hasSuffix("2") { term = 3 }
        else { term = 1 }
        return year * 4 + term
    }

    private static func fallbackSemester(now: Date = Date()) -> String {
        let calendar = Calendar.koin
        let year = calendar.component(.year, from: now)
        switch calendar.component(.month, from: now) {
        case 1...2: return "\(year - 1)-겨울"
        case 3...6: return "\(year)1"
        case 7...8: return "\(year)-여름"
        default: return "\(year)2"
        }
    }
}
