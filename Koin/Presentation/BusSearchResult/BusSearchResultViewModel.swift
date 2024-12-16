//
//  BusSearchResultViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine

final class BusSearchResultViewModel: ViewModelProtocol {
    enum Input {
        case getDatePickerData
        case getSearchedResult(String, BusType)
    }
    enum Output {
        case updateDatePickerData(([[String]], [String]))
        case udpatesSearchedResult(SearchBusInfoResult)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    let busPlaces: (BusPlace, BusPlace)  // navigationItem을 설정하기 위해 private 임시 없앰
    private let fetchDatePickerDataUseCase: FetchKoinPickerDataUseCase
    private let fetchSearchedResultUseCase: SearchBusInfoUseCase
    
    init(fetchDatePickerDataUseCase: FetchKoinPickerDataUseCase, busPlaces: (BusPlace, BusPlace), fetchSearchedResultUseCase: SearchBusInfoUseCase) {
        self.fetchDatePickerDataUseCase = fetchDatePickerDataUseCase
        self.fetchSearchedResultUseCase = fetchSearchedResultUseCase
        self.busPlaces = busPlaces
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getDatePickerData:
                self?.getDatePickerData()
            case let .getSearchedResult(departDate, busType):
                self?.getSearchedResult(departDate: departDate, busType: busType)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension BusSearchResultViewModel {
    private func getDatePickerData() {
        let data = fetchDatePickerDataUseCase.execute()
        outputSubject.send(.updateDatePickerData(data))
    }
    
    private func getSearchedResult(departDate: String, busType: BusType) {
        fetchSearchedResultUseCase.execute(date: departDate, busType: busType, departure: busPlaces.0, arrival: busPlaces.1).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] searchedResult in
            self?.outputSubject.send(.udpatesSearchedResult(searchedResult))
        }).store(in: &subscriptions)
    }
}
