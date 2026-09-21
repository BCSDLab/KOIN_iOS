//
//  PublisherTestError.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/8/26.
//

import Combine
import Foundation

enum PublisherTestError: Error {
    case finishedWithoutValue
}

extension Publisher {
    /// Combine 파이프라인이 방출하는 첫 번째 값을 async로 받아온다.
    ///
    /// 프로덕션 코드가 `AnyPublisher`를 반환하기 때문에, Swift Testing의 `async` 테스트에서
    /// `await`로 결과를 기다리기 위해 `Publisher.values`(AsyncSequence)를 경유한다.
    func firstValue() async throws -> Output {
        for try await value in values {
            return value
        }
        throw PublisherTestError.finishedWithoutValue
    }
}
