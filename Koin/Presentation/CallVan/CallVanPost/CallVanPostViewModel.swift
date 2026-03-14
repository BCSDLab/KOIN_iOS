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
        case updateDepartureDate(String) // "yyyy-MM-dd"
        case updateDepartureTime(String) // "HH:mm"
        case updateMaxParticipants(Int)
        case swapButtonTapped
    }
    enum Output {
        case enablePostButton(Bool)
        case updateDeparture(CallVanPlace?, String?)
        case updateArrival(CallVanPlace?, String?)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var request = CallVanPostRequest() {
        didSet {
            validateRequest()
        }
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
            case let .updateDepartureDate(departureDate): // "yyyy-MM-dd"
                request.departureDate = departureDate
            case let .updateDepartureTime(departureTime): // "HH:mm"
                request.departureTime = departureTime
            case let .updateMaxParticipants(maxParticipants):
                request.maxParticipants = maxParticipants
            case .swapButtonTapped:
                swapPlace()
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanPostViewModel {
    
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
}
