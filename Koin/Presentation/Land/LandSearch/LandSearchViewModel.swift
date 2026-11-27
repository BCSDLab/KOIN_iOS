//
//  LandSearchViewModel.swift
//  koin
//
//  Created by 홍기정 on 11/24/26.
//

import Foundation
import Combine

final class LandSearchViewModel: ViewModelProtocol {
    enum Input {
        case viewDidLoad
        case searchTextChanged(String)
        case search(String)
        case logEvent(EventLabelType, Any, parameters: [String: String] = [:])
    }
    enum Output {
        case updateSuggestions(query: String, rows: [LandRow])
        case updateLandList(LandList)
        case showToastMessage(String)
    }

    // MARK: - Properties
    private static let suggestionCount = 3
    private let fetchLandListUseCase: FetchLandListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var changeSuggestionTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?

    // MARK: - Initializer
    init(
        fetchLandListUseCase: FetchLandListUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.fetchLandListUseCase = fetchLandListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
}

extension LandSearchViewModel {
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                fetchLandList()
            case let .searchTextChanged(query):
                changeSuggestionIfPossible(query: query)
            case let .search(query):
                search(query: query)
            case let .logEvent(label, value, parameters):
                makeLogEvent(label, value, parameters)
            }
        }
        .store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LandSearchViewModel {
    private func changeSuggestionIfPossible(query: String) {
        changeSuggestionTask?.cancel()
        changeSuggestionTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(300))
                guard let self else { return }
                
                let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
                let output: [LandRow]
                
                if query.isEmpty {
                    output = []
                } else {
                    let prefixes = try await fetchLandList(query: query)
                        .rows
                        .prefix(Self.suggestionCount)
                    output = Array(prefixes)
                }
                outputSubject.send(.updateSuggestions(query: query, rows: output))
            } catch {
                guard !Task.isCancelled else { return }
                let error = (error as? ErrorResponse) ?? ErrorResponse.unexpectedInternalError
                self?.outputSubject.send(.showToastMessage(error.message))
            }
        }
    }
    
    private func search(query: String) {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return
        }
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let list = try await fetchLandList(query: query)
                guard !Task.isCancelled else { return }
                outputSubject.send(.updateLandList(list))
            } catch {
                guard !Task.isCancelled else { return }
                let error = (error as? ErrorResponse) ?? ErrorResponse.unexpectedInternalError
                outputSubject.send(.showToastMessage(error.message))
            }
        }
    }
    
    private func fetchLandList() {
        searchTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let list = try await fetchLandList(query: nil)
                guard !Task.isCancelled else { return }
                outputSubject.send(.updateLandList(list))
            } catch {
                guard !Task.isCancelled else { return }
                let error = (error as? ErrorResponse) ?? ErrorResponse.unexpectedInternalError
                outputSubject.send(.showToastMessage(error.message))
            }
        }
    }
}

extension LandSearchViewModel {
    private func fetchLandList(query: String?) async throws -> LandList {
        do {
            return try await fetchLandListUseCase.execute(query: query).firstValue()
        } catch {
            throw error
        }
    }
    
    private func makeLogEvent(
        _ label: EventLabelType,
        _ value: Any,
        _ parameters: [String: String] = [:]
    ) {
        logAnalyticsEventUseCase.execute(
            label: label,
            value: value,
            parameters: parameters
        )
    }
}
