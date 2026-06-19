import Foundation
import Combine

protocol CheckModifyUserNeededUseCase {
    func execute() -> AnyPublisher<Bool, ErrorResponse>
}

final class DefaultCheckModifyUserNeededUseCase: CheckModifyUserNeededUseCase {

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute() -> AnyPublisher<Bool, ErrorResponse> {
        userRepository.fetchUserData()
            .handleEvents(receiveOutput: { userData in
                UserDataManager.shared.setUserData(userData: userData)
            })
            .map { userData in
                if UserDefaults.standard.bool(forKey: "forceModal") {
                    return false
                }

                guard userData.userType == "STUDENT" else { return false }

                let needsModify = userData.name == nil ||
                    userData.phoneNumber == nil ||
                    userData.gender == nil ||
                    userData.major == nil ||
                    userData.studentNumber == nil

                if needsModify {
                    UserDefaults.standard.set(true, forKey: "forceModal")
                }

                return needsModify
            }
            .eraseToAnyPublisher()
    }
}
