//
//  CallVanPostViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

final class CallVanPostViewModel: ViewModelProtocol {
    
    enum Input {
        case updateDeparture(CallVanPlace?, String?)
        case updateArrival(CallVanPlace?, String?)
        case updateDepartureDate(Date) // "yyyy-MM-dd"
        case updateDepartureTime(Date) // "HH:mm"
        case updateMaxParticipants(Int)
        case swapButtonTapped
        case postData
        case logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any)
    }
    enum Output {
        case enablePostButton(Bool)
        case updateDeparture(CallVanPlace?, String?)
        case updateArrival(CallVanPlace?, String?)
        case postDataCompleted(CallVanListPost)
        case showToast(String)
        case showRestrictedModal(type: RestrictionType?, until: String?)
    }
    
    // MARK: - Properties
    private let postCallVanDataUseCase: PostCallVanDataUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchCallVanRestrictionUseCase: FetchCallVanRestrictionUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let dateFormatter = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
    }
    private(set) var request = CallVanPostRequest() {
        didSet {
            validate()
        }
    }
    
    // MARK: - Initializer
    init(
        postCallVanDataUseCase: PostCallVanDataUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        fetchCallVanRestrictionUseCase: FetchCallVanRestrictionUseCase
    ) {
        self.postCallVanDataUseCase = postCallVanDataUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchCallVanRestrictionUseCase = fetchCallVanRestrictionUseCase
    }
    
    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case let .updateDeparture(departureType, customPlace):
                request.departureType = departureType
                request.departureCustomName = customPlace
            case let .updateArrival(arrivalType, customPlace):
                request.arrivalType = arrivalType
                request.arrivalCustomName = customPlace
            case let .updateDepartureDate(departureDate):
                updateDepartureDate(departureDate)
            case let .updateDepartureTime(departureTime):
                updateDepartureTime(departureTime)
            case let .updateMaxParticipants(maxParticipants):
                request.maxParticipants = maxParticipants
            case .swapButtonTapped:
                swapPlace()
            case .postData:
                checkRestriction()
            case let .logEvent(label, category, value):
                logEvent(label: label, category: category, value: value)
                
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanPostViewModel {
    
    private func updateDepartureDate(_ departureDate: Date) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        request.departureDate = dateFormatter.string(from: departureDate)
    }
    
    private func updateDepartureTime(_ departureTime: Date) {
        dateFormatter.dateFormat = "HH:mm"
        request.departureTime = dateFormatter.string(from: departureTime)
    }
    
    private func swapPlace() {
        let departureType = request.departureType
        let departureCustomName = request.departureCustomName
        request.departureType = request.arrivalType
        request.departureCustomName = request.arrivalCustomName
        request.arrivalType = departureType
        request.arrivalCustomName = departureCustomName
        
        outputSubject.send(.updateDeparture(request.departureType, request.departureCustomName))
        outputSubject.send(.updateArrival(request.arrivalType, request.arrivalCustomName))
    }
    
    private func validate() {
        var isValid = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let tenMinutes: TimeInterval = 1 * 60 * 10
        
        /// 빈 값이 있는지 확인
        if request.departureType == nil
            || request.arrivalType == nil
            || request.departureDate?.isEmpty == true
            || request.departureTime?.isEmpty == true {
            isValid = false
        }
        
        /// 출발지와 도착지가 다른지 확인
        switch (request.departureType, request.arrivalType) {
        case (.custom, .custom):
            if request.departureCustomName == request.arrivalCustomName {
                isValid = false
            }
        default:
            if request.departureType == request.arrivalType {
                isValid = false
            }
        }
        
        /// 현재 시각으로부터 최소 10분 이후 일정인지 확인
        let date = request.departureDate ?? ""
        let time = request.departureTime ?? ""
        if let requestDate = formatter.date(from: "\(date) \(time)"),
           requestDate.timeIntervalSince(Date()) < tenMinutes {
            isValid = false
        }
        
        outputSubject.send(.enablePostButton(isValid))
    }
    
    private func checkRestriction() {
        fetchCallVanRestrictionUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] restriction in
                if restriction.isRestricted {
                    self?.outputSubject.send(.showRestrictedModal(type: restriction.restrictionType, until: restriction.restrictedUntil))
                } else {
                    self?.postData()
                }
            }
        ).store(in: &subscriptions)
    }
    
    private func postData() {
        postCallVanDataUseCase.execute(request: request).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] postData in
                self?.outputSubject.send(.postDataCompleted(postData))
            }
        ).store(in: &subscriptions)
    }
    
    private func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
