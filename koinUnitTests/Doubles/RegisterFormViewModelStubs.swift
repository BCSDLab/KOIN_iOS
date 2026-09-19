//
//  RegisterFormViewModelStubs.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/10/26.
//

import Combine
import Foundation
@testable import koin

final class SpyLogAnalyticsEventUseCase: LogAnalyticsEventUseCase {

    struct SessionEvent: Equatable {
        let label: String
        let category: EventParameter.EventCategory
        let value: String
        let sessionId: String
    }

    private(set) var sessionEvents: [SessionEvent] = []

    var executeWithSessionIdCallCount: Int { sessionEvents.count }

    func execute(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) { }

    func executeWithDuration(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any,
        previousPage: String?,
        currentPage: String?,
        durationTime: String?
    ) { }

    func logEvent(
        name: String,
        label: String,
        value: String,
        category: String
    ) { }

    func executeWithSessionId(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any,
        sessionId: String
    ) {
        sessionEvents.append(
            SessionEvent(
                label: label.rawValue,
                category: category,
                value: "\(value)",
                sessionId: sessionId
            )
        )
    }
}

final class StubCheckDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase {
    func execute(phone: String) -> AnyPublisher<Void, ErrorResponse> {
        Empty<Void, ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubSendVerificationCodeUseCase: SendVerificationCodeUsecase {
    func execute(request: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDto, ErrorResponse> {
        Empty<SendVerificationCodeDto, ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubCheckVerificationCodeUseCase: CheckVerificationCodeUsecase {
    func execute(phoneNumber: String, verificationCode: String) -> AnyPublisher<Void, ErrorResponse> {
        Empty<Void, ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubCheckDuplicatedIdUseCase: CheckDuplicatedIdUsecase {
    func execute(loginId: String) -> AnyPublisher<Void, ErrorResponse> {
        Empty<Void, ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubFetchDeptListUseCase: FetchDeptListUseCase {
    func execute() -> AnyPublisher<[String], ErrorResponse> {
        Empty<[String], ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubCheckDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase {
    func execute(nickname: String) -> AnyPublisher<Void, ErrorResponse> {
        Empty<Void, ErrorResponse>().eraseToAnyPublisher()
    }
}

final class StubRegisterFormUseCase: RegisterFormUseCase {
    func studentExecute(
        name: String,
        phoneNumber: String,
        loginId: String,
        password: String,
        department: String,
        studentNumber: String,
        gender: String,
        email: String?,
        nickname: String?
    ) -> AnyPublisher<Void, ErrorResponse> {
        Empty<Void, ErrorResponse>().eraseToAnyPublisher()
    }

    func generalExecute(
        name: String,
        phoneNumber: String,
        loginId: String,
        gender: String,
        password: String,
        email: String?,
        nickname: String?
    ) -> AnyPublisher<Void, ErrorResponse> {
        Empty<Void, ErrorResponse>().eraseToAnyPublisher()
    }
}

extension RegisterFormViewModel {
    static func withSpy(_ spy: SpyLogAnalyticsEventUseCase) -> RegisterFormViewModel {
        RegisterFormViewModel(
            checkDuplicatedPhoneNumberUseCase: StubCheckDuplicatedPhoneNumberUseCase(),
            sendVerificationCodeUseCase: StubSendVerificationCodeUseCase(),
            checkVerificationCodeUseCase: StubCheckVerificationCodeUseCase(),
            checkDuplicatedIdUseCase: StubCheckDuplicatedIdUseCase(),
            fetchDeptListUseCase: StubFetchDeptListUseCase(),
            checkDuplicatedNicknameUseCase: StubCheckDuplicatedNicknameUseCase(),
            registerFormUseCase: StubRegisterFormUseCase(),
            logAnalyticsEventUseCase: spy
        )
    }
}

final class OutputRecorder {

    private let viewModel: RegisterFormViewModel
    private let input = PassthroughSubject<RegisterFormViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    private(set) var outputs: [RegisterFormViewModel.Output] = []

    init(_ viewModel: RegisterFormViewModel) {
        self.viewModel = viewModel
        viewModel.transform(with: input.eraseToAnyPublisher())
            .sink { [weak self] in self?.outputs.append($0) }
            .store(in: &subscriptions)
    }

    func send(_ value: RegisterFormViewModel.Input) {
        input.send(value)
    }

    var httpResultMessages: [String] {
        outputs.compactMap { if case let .showHttpResult(message, _) = $0 { return message } else { return nil } }
    }

    var httpResultColors: [ColorAsset] {
        outputs.compactMap { if case let .showHttpResult(_, color) = $0 { return color } else { return nil } }
    }
}
