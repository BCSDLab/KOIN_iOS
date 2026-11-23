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
    }
    enum Output {
        case updateLandList(LandList)
        case showToastMessage(String)
    }

    // MARK: - Properties
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
            .filter { !$0.isEmpty }
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
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
