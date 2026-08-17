//
//  DiningViewModelStubs.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/17/26.
//

import Alamofire
import Combine
import Foundation
@testable import koin

final class StubFetchDiningListUseCase: FetchDiningListUseCase {
    func execute(diningInfo: CurrentDiningTime) -> AnyPublisher<[DiningItem], ErrorResponse> {
        Empty<[DiningItem], ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubDateProvider: DateProvider {
    func execute(date: Date) -> CurrentDiningTime {
        CurrentDiningTime(date: date, diningType: .breakfast)
    }
}

final class StubShareMenuListUseCase: ShareMenuListUseCase {
    func execute(shareModel: ShareDiningMenu) {}
}

final class StubChangeNotiUseCase: ChangeNotiUseCase {
    func execute(method: Alamofire.HTTPMethod, type: SubscribeType) -> AnyPublisher<Void, ErrorResponse> {
        Empty<Void, ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubChangeNotiDetailUseCase: ChangeNotiDetailUseCase {
    func execute(method: Alamofire.HTTPMethod, detailType: DetailSubscribeType) -> AnyPublisher<Void, ErrorResponse> {
        Empty<Void, ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubFetchNotiListUseCase: FetchNotiListUseCase {
    func execute() -> AnyPublisher<NotiAgreementDto, ErrorResponse> {
        Empty<NotiAgreementDto, ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubLogAnalyticsEventUseCase: LogAnalyticsEventUseCase {
    func execute(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {}

    func executeWithDuration(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?) {}

    func logEvent(name: String, label: String, value: String, category: String) {}

    func executeWithSessionId(label: EventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String) {}
}
