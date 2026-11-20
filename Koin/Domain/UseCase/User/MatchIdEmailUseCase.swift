//
//  MatchIdEmailUseCase.swift
//  koin
//

import Combine

protocol MatchIdEmailUseCase {
    func execute(requestModel: MatchIdEmailRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultMatchIdEmailUseCase: MatchIdEmailUseCase {

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute(requestModel: MatchIdEmailRequest) -> AnyPublisher<Void, ErrorResponse> {
        return userRepository.matchIdEmail(requestModel: requestModel)
    }
}
