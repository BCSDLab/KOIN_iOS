//
//  CertificationUseCaseSpies.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/14/26.
//

import Combine
import Foundation
@testable import koin

final class SpyCheckDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase {

    var stubbedResult: Result<Void, ErrorResponse> = .success(())
    private(set) var receivedPhoneNumbers: [String] = []

    func execute(phone: String) -> AnyPublisher<Void, ErrorResponse> {
        receivedPhoneNumbers.append(phone)
        return stubbedResult.publisher.eraseToAnyPublisher()
    }
}

final class SpySendVerificationCodeUseCase: SendVerificationCodeUsecase {

    var stubbedResult: Result<SendVerificationCodeDto, ErrorResponse> = .success(
        SendVerificationCodeDto(
            target: "01012345678",
            totalCount: 5,
            remainingCount: 4,
            currentCount: 1
        )
    )
    
    private(set) var receivedRequests: [SendVerificationCodeRequest] = []

    func execute(request: SendVerificationCodeRequest) -> AnyPublisher<SendVerificationCodeDto, ErrorResponse> {
        receivedRequests.append(request)
        return stubbedResult.publisher.eraseToAnyPublisher()
    }
}

final class SpyCheckVerificationCodeUseCase: CheckVerificationCodeUsecase {

    struct Received: Equatable {
        let phoneNumber: String
        let verificationCode: String
    }

    var stubbedResult: Result<Void, ErrorResponse> = .success(())
    
    private(set) var receivedCodes: [Received] = []

    func execute(phoneNumber: String, verificationCode: String) -> AnyPublisher<Void, ErrorResponse> {
        receivedCodes.append(Received(phoneNumber: phoneNumber, verificationCode: verificationCode))
        return stubbedResult.publisher.eraseToAnyPublisher()
    }
}

extension RegisterFormViewModel {
    static func makeForCertification(
        checkDuplicatedPhoneNumberUseCase: CheckDuplicatedPhoneNumberUseCase = StubCheckDuplicatedPhoneNumberUseCase(),
        sendVerificationCodeUseCase: SendVerificationCodeUsecase = StubSendVerificationCodeUseCase(),
        checkVerificationCodeUseCase: CheckVerificationCodeUsecase = StubCheckVerificationCodeUseCase(),
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase = SpyLogAnalyticsEventUseCase()
    ) -> RegisterFormViewModel {
        RegisterFormViewModel(
            checkDuplicatedPhoneNumberUseCase: checkDuplicatedPhoneNumberUseCase,
            sendVerificationCodeUseCase: sendVerificationCodeUseCase,
            checkVerificationCodeUseCase: checkVerificationCodeUseCase,
            checkDuplicatedIdUseCase: StubCheckDuplicatedIdUseCase(),
            fetchDeptListUseCase: StubFetchDeptListUseCase(),
            checkDuplicatedNicknameUseCase: StubCheckDuplicatedNicknameUseCase(),
            registerFormUseCase: StubRegisterFormUseCase(),
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
    }
}
