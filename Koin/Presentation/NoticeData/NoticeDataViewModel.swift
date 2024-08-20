//
//  NoticeDataViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import Foundation

final class NoticeDataViewModel: ViewModelProtocol {
    
    enum Input {
        case getNoticeData
    }
    enum Output {
        case updateNoticeData(NoticeDataInfo)
    }
    
    private let fetchNoticeDataUseCase: FetchNoticeDataUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var noticeId: Int = 0
    
    init(fetchNoticeDataUseCase: FetchNoticeDataUseCase, noticeId: Int) {
        self.fetchNoticeDataUseCase = fetchNoticeDataUseCase
        self.noticeId = noticeId
    }

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getNoticeData:
                self?.getNoticeData()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeDataViewModel {
    func getNoticeData() {
        print("asdaf")
        let request = FetchNoticeDataRequest(noticeId: noticeId)
        fetchNoticeDataUseCase.fetchNoticeData(request: request).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] noticeData in
            print(noticeData)
            self?.outputSubject.send(.updateNoticeData(noticeData))
        }).store(in: &subscriptions)
    }
}

