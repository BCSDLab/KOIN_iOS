////
////  TimeTableViewModel.swift
////  koin
////
////  Created by 김나훈 on 3/29/24.
////
//
//
//import Alamofire
//import Combine
//import Foundation
//
//final class TimetableViewModel: ViewModelProtocol {
//    
//    // MARK: - Input
//    
//    enum Input {
//        case getSemesterList
//        case changeSemester(SemesterDTO)
//        case filterClass(String?)
//        case addLecture(LectureDTO, String)
//        case deleteTimetable(Int)
//    }
//    
//    // MARK: - Output
//    
//    enum Output {
//        case initSemesterList([SemesterDTO])
//        case updateTimetables(TimetablesDTO, SemesterDTO?)
//        case updateFilteredLecture([LectureDTO])
//        case deleteTimetable(Int)
//        case requestLogInAgain
//    }
//    
//    // MARK: - Properties
//    
//    private let outputSubject = PassthroughSubject<Output, Never>()
//    private let service: TimetableService
//    private var subscriptions: Set<AnyCancellable> = []
//    private (set) var lectureList: [LectureDTO] = []
//    
//    // MARK: - Initialization
//    
//    init(service: TimetableService) {
//        self.service = service
//    }
//    
//    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
//        input.sink { [weak self] input in
//            switch input {
//            case .getSemesterList:
//                self?.getSemesterList()
//            case let .changeSemester(semester):
//                self?.getTimetables(semester: semester)
//                self?.getLectureList(semester: semester.semester)
//            case let .filterClass(text):
//                self?.filterClass(text: text)
//            case let .addLecture(lecture, semester):
//                self?.addLecture(lecture, semester)
//            case let .deleteTimetable(timetableId):
//                self?.deleteTimetable(timetableId)
//            }
//        }.store(in: &subscriptions)
//        return outputSubject.eraseToAnyPublisher()
//    }
//    
//}
//
//extension TimetableViewModel {
//    
//    private func refreshTokenAndRetryRequest(_ retryRequest: @escaping () -> Void) {
//        UserLogInWorker.shared.refreshAccessToken { [weak self] success in
//            if success {
//                retryRequest()
//            }
//            else {
//                self?.outputSubject.send(.requestLogInAgain)
//            }
//        }
//    }
//    
//    private func deleteTimetable(_ id: Int, retryAttempted: Bool = false) {
//        
//        let token = KeyChainWorker.shared.read(key: .access) ?? ""
//        let headers: Alamofire.HTTPHeaders = [
//            "Authorization": "Bearer \(token)",
//            "Content-Type": "application/json"
//        ]
//        
//        let parameter = Removetimetable(id: id)
//        AF.request("\(stageUrl)/timetable", method: .delete, parameters: parameter, headers: headers)
//            .validate(statusCode: 200..<300)
//            .response { [weak self] response in
//                guard let strongSelf = self else { return }
//                if response.error != nil, !retryAttempted {
//                    strongSelf.refreshTokenAndRetryRequest {
//                        strongSelf.deleteTimetable(id, retryAttempted: true)
//                    }
//                } else if let error = response.error {
//                    strongSelf.outputSubject.send(.requestLogInAgain)
//                } else {
//                    strongSelf.outputSubject.send(.deleteTimetable(id))
//                }
//            }
//    }
//    
//    private func addLecture(_ lecture: LectureDTO, _ semester: String, retryAttempted: Bool = false) {
//        let postTimetableRequest = TimetableRequest(timetable: [timetablePostRequest(code: lecture.code, name: lecture.name, grades: lecture.grades, lectureClass: lecture.lectureClass, regularNumber: lecture.regularNumber, department: lecture.department, target: lecture.target, professor: lecture.professor, isEnglish: lecture.isEnglish, designScore: lecture.designScore, isElearning: lecture.isEnglish, classTime: lecture.classTime, classPlace: nil, memo: nil)], semester: semester)
//
//        let token = KeyChainWorker.shared.read(key: .access) ?? ""
//    
//        service.postTimetables(request: postTimetableRequest, token: token) .sink { [weak self] completion in
//            if case let .failure(error) = completion {
//                if !retryAttempted {
//                    self?.refreshTokenAndRetryRequest {
//                        self?.addLecture(lecture, semester, retryAttempted: true)
//                    }
//                } else {
//                    self?.outputSubject.send(.requestLogInAgain)
//                }
//            }
//        }receiveValue: { [weak self] response in
//            self?.outputSubject.send(.updateTimetables(response, SemesterDTO(id: 0, semester: semester)))
//        }.store(in: &subscriptions)
//        
//    }
//    private func filterClass(text: String?) {
//        let filteredLectures: [LectureDTO]
//        if let searchText = text, !searchText.isEmpty {
//            filteredLectures = lectureList.filter { lecture in
//                lecture.name.lowercased().contains(searchText.lowercased())
//            }
//        } else {
//            filteredLectures = lectureList
//        }
//        outputSubject.send(.updateFilteredLecture(filteredLectures))
//    }
//    // 학기 정보를 가져오는 함수
//    private func getSemesterList() {
//        service.getSemesterList().sink {  completion in
//            if case let .failure(error) = completion {
//                Log.make().error("\(error)")
//            }
//        } receiveValue: { [weak self] response in
//            self?.outputSubject.send(.initSemesterList(response))
//            self?.getLectureList(semester: response.first?.semester)
//            self?.getTimetables(semester: response.first)
//        }.store(in: &subscriptions)
//    }
//    
//    // 강의 리스트 가져오는 함수
//    private func getLectureList(semester: String?) {
//        guard let semester = semester else { return }
//        service.getLectureList(semester: semester).sink { completion in
//            if case let .failure(error) = completion {
//                Log.make().error("\(error)")
//            }
//        } receiveValue: { [weak self] response in
//            self?.lectureList = response
//        }.store(in: &subscriptions)
//    }
//    
//    // 해당 학기의 내 시간표를 가져오는 함수
//    private func getTimetables(semester: SemesterDTO?, retryAttempted: Bool = false) {
//        
//        guard let semesterName = semester?.semester else { return }
//        let token = KeyChainWorker.shared.read(key: .access) ?? ""
//        
//        service.getTimetables(semester: semesterName, token: token).sink { [weak self] completion in
//            if case let .failure(error) = completion {
//                if !retryAttempted {
//                    self?.refreshTokenAndRetryRequest {
//                        self?.getTimetables(semester: semester, retryAttempted: true)
//                    }
//                } else {
//                    self?.outputSubject.send(.requestLogInAgain)
//                }
//            }
//        } receiveValue: { [weak self] response in
//            self?.outputSubject.send(.updateTimetables(response, semester))
//        }.store(in: &subscriptions)
//        
//    }
//}
