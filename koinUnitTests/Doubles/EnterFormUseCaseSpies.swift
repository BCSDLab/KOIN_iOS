//
//  EnterFormUseCaseSpies.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/19/26.
//

import Combine
import Foundation
@testable import koin

final class SpyCheckDuplicatedIdUseCase: CheckDuplicatedIdUsecase {

    var stubbedResult: Result<Void, ErrorResponse> = .success(())
    private(set) var receivedLoginIds: [String] = []

    func execute(loginId: String) -> AnyPublisher<Void, ErrorResponse> {
        receivedLoginIds.append(loginId)
        return stubbedResult.publisher.eraseToAnyPublisher()
    }
}

final class SpyFetchDeptListUseCase: FetchDeptListUseCase {

    var stubbedResult: Result<[String], ErrorResponse> = .success([])
    private(set) var executeCallCount = 0

    func execute() -> AnyPublisher<[String], ErrorResponse> {
        executeCallCount += 1
        return stubbedResult.publisher.eraseToAnyPublisher()
    }
}

final class SpyCheckDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase {

    var stubbedResult: Result<Void, ErrorResponse> = .success(())
    private(set) var receivedNicknames: [String] = []

    func execute(nickname: String) -> AnyPublisher<Void, ErrorResponse> {
        receivedNicknames.append(nickname)
        return stubbedResult.publisher.eraseToAnyPublisher()
    }
}

final class SpyRegisterFormUseCase: RegisterFormUseCase {

    struct StudentRequest: Equatable {
        let name, phoneNumber, loginId, password, department, studentNumber, gender: String
        let email, nickname: String?
    }

    struct GeneralRequest: Equatable {
        let name, phoneNumber, loginId, gender, password: String
        let email, nickname: String?
    }

    var stubbedResult: Result<Void, ErrorResponse> = .success(())
    private(set) var studentRequests: [StudentRequest] = []
    private(set) var generalRequests: [GeneralRequest] = []

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
        studentRequests.append(
            StudentRequest(
                name: name,
                phoneNumber: phoneNumber,
                loginId: loginId,
                password: password,
                department: department,
                studentNumber: studentNumber,
                gender: gender,
                email: email,
                nickname: nickname
            )
        )
        return stubbedResult.publisher.eraseToAnyPublisher()
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
        generalRequests.append(
            GeneralRequest(
                name: name,
                phoneNumber: phoneNumber,
                loginId: loginId,
                gender: gender,
                password: password,
                email: email,
                nickname: nickname
            )
        )
        return stubbedResult.publisher.eraseToAnyPublisher()
    }
}

extension RegisterFormViewModel {
    static func makeForEnterForm(
        checkDuplicatedIdUseCase: CheckDuplicatedIdUsecase = StubCheckDuplicatedIdUseCase(),
        fetchDeptListUseCase: FetchDeptListUseCase = StubFetchDeptListUseCase(),
        checkDuplicatedNicknameUseCase: CheckDuplicatedNicknameUseCase = StubCheckDuplicatedNicknameUseCase(),
        registerFormUseCase: RegisterFormUseCase = StubRegisterFormUseCase()
    ) -> RegisterFormViewModel {
        RegisterFormViewModel(
            checkDuplicatedPhoneNumberUseCase: StubCheckDuplicatedPhoneNumberUseCase(),
            sendVerificationCodeUseCase: StubSendVerificationCodeUseCase(),
            checkVerificationCodeUseCase: StubCheckVerificationCodeUseCase(),
            checkDuplicatedIdUseCase: checkDuplicatedIdUseCase,
            fetchDeptListUseCase: fetchDeptListUseCase,
            checkDuplicatedNicknameUseCase: checkDuplicatedNicknameUseCase,
            registerFormUseCase: registerFormUseCase,
            logAnalyticsEventUseCase: SpyLogAnalyticsEventUseCase()
        )
    }
}
