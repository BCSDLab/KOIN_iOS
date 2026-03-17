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
    }
    enum Output {
        case enablePostButton(Bool)
        case updateDeparture(CallVanPlace?, String?)
        case updateArrival(CallVanPlace?, String?)
        case postDataCompleted(CallVanListPost)
        case showToast(String)
    }
    
    // MARK: - Properties
    private let postCallVanDataUseCase: PostCallVanDataUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let dateFormatter = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
    }
    private(set) var request = CallVanPostRequest() {
        didSet {
            validateRequest()
        }
    }
    
    // MARK: - Initializer
    init(postCallVanDataUseCase: PostCallVanDataUseCase) {
        self.postCallVanDataUseCase = postCallVanDataUseCase
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
                postData()
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
    
    private func validateRequest() {
        let validation = request.departureType != nil
            && request.arrivalType != nil
            && request.departureDate != nil
            && request.departureTime != nil
        
        outputSubject.send(.enablePostButton(validation))
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
}
