//
//  FilterBottomSheetViewModel.swift
//  koin
//
//  Created by 김성민 on 9/26/25.
//

import Foundation
import Combine

final class FilterBottomSheetViewModel: ViewModelProtocol {
    
    enum Input {
        case togglePeriod(OrderHistoryPeriod)
        case toggleType(OrderHistoryType)
        case toggleStatus(OrderHistoryStatus)
        case reset
        case apply
        case close
    }
    
    enum Output {
        case render(State)
        case applied(OrderHistoryQuery)
        case dismiss
    }
    
    struct State {
        let period: OrderHistoryPeriod
        let type: OrderHistoryType
        let status: OrderHistoryStatus
    }
    
    private var query: OrderHistoryQuery
    private let output = PassthroughSubject<Output,Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(initial: OrderHistoryQuery) { self.query = initial }
    
    func transform(with input: AnyPublisher<Input,Never>) -> AnyPublisher<Output,Never> {
        input
            .sink { [weak self] input in
                guard let self else { return }
                switch input {
                case .togglePeriod(let period):
                    self.togglePeriod(period)
                    
                case .toggleType(let type):
                    self.toggleType(type)
                    
                case .toggleStatus(let status):
                    self.toggleStatus(status)
                    
                case .reset:
                    self.reset()
                    
                case .apply:
                    self.apply()
                    
                case .close:
                    self.close()
                }
            }
            .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func togglePeriod(_ period: OrderHistoryPeriod) {
        query.period = (query.period == period) ? .none : period
        ()
        updateState()
    }
    
    private func toggleType(_ type: OrderHistoryType) {
        query.type = (query.type == type) ? .none : type
        updateState()
    }
    
    private func toggleStatus(_ status: OrderHistoryStatus) {
        query.status = (query.status == status) ? .none : status
        updateState()
    }
    
    private func reset() {
        query.resetFilter()
        updateState()
    }
    
    private func apply() {
        output.send(.applied(query))
        output.send(.dismiss)
    }
    
    private func close() {
        output.send(.dismiss)
    }
    
    private func updateState() {
        output.send(.render(
            State(
                period: query.period,
                type: query.type,
                status: query.status
            )
        ))
    }
    
}

