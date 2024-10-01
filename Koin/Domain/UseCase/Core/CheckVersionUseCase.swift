//
//  FetchVersionUseCase.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Combine
import Foundation


protocol CheckVersionUseCase {
    func execute() -> AnyPublisher<Bool, Error>
}

final class DefaultCheckVersionUseCase: CheckVersionUseCase {
    
    private let coreRepository: CoreRepository
    
    init(coreRepository: CoreRepository) {
        self.coreRepository = coreRepository
    }
    
    func execute() -> AnyPublisher<Bool, Error> {
        return coreRepository.fetchVersion()
            .map { response in
                let currentVersion = self.checkNowVersion()  // 현재 버전 확인
                return self.isVersion(currentVersion, lowerThan: response.version)  // 버전 비교 후 Bool 반환
            }
            .eraseToAnyPublisher()
    }
    
    private func checkNowVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    private func isVersion(_ currentVersion: String, lowerThan requiredVersion: String) -> Bool {
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        let requiredComponents = requiredVersion.split(separator: ".").compactMap { Int($0) }
        
        for i in 0..<max(currentComponents.count, requiredComponents.count) {
            let current = i < currentComponents.count ? currentComponents[i] : 0
            let required = i < requiredComponents.count ? requiredComponents[i] : 0
            if current < required {
                return true  // 현재 버전이 낮음
            } else if current > required {
                return false  // 현재 버전이 높음
            }
        }
        return false  // 두 버전이 동일한 경우
    }
}
