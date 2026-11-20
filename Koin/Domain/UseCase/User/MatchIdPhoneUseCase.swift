//
//  MatchIdPhoneUseCase.swift
//  koin
//

import Combine

protocol MatchIdPhoneUseCase {
    func execute(requestModel: MatchIdPhoneRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultMatchIdPhoneUseCase: MatchIdPhoneUseCase {

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute(requestModel: MatchIdPhoneRequest) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.matchIdPhone(requestModel: requestModel)
    }
}
