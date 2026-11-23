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
        case searchTextChanged(String)
        case search(String)
    }
    enum Output {
        case updateSuggestions(query: String, rows: [LandRow])
        case updateLandList(LandList)
        case showToastMessage(String)
    }

    // MARK: - Properties
    private static let suggestionCount = 3
    private let fetchLandListUseCase: FetchLandListUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Initializer
    init(fetchLandListUseCase: FetchLandListUseCase) {
        self.fetchLandListUseCase = fetchLandListUseCase
    }
}

extension LandSearchViewModel {
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .compactMap { input -> String? in
                guard case let .searchTextChanged(text) = input else { return nil }
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { [weak self] query -> AnyPublisher<Output, Never> in
                guard let self, !query.isEmpty else {
                    return Just(Output.updateSuggestions(query: query, rows: [])).eraseToAnyPublisher()
                }
                return fetchLandList(query: query)
                    .map { Output.updateSuggestions(query: query, rows: Array($0.rows.prefix(Self.suggestionCount))) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { [weak self] output in
                self?.outputSubject.send(output)
            }
            .store(in: &subscriptions)

        input
            .compactMap { input -> String? in
                guard case let .search(text) = input else { return nil }
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
            .map { [weak self] query -> AnyPublisher<LandList, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return fetchLandList(query: query)
            }
            .switchToLatest()
            .sink { [weak self] landList in
                self?.outputSubject.send(.updateLandList(landList))
            }
            .store(in: &subscriptions)

        return outputSubject.eraseToAnyPublisher()
    }
}

extension LandSearchViewModel {
    private func fetchLandList(query: String) -> AnyPublisher<LandList, Never> {
        fetchLandListUseCase.execute(query: query)
            .catch { [weak self] error -> Empty<LandList, Never> in
                self?.outputSubject.send(.showToastMessage(error.message))
                return Empty()
            }
            .eraseToAnyPublisher()
    }
}
