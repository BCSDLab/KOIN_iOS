//
//  Publisher+.swift
//  koin
//
//  Created by 홍기정 on 6/17/26.
//

import Combine

extension Publisher where Failure: Error {
    func async() async throws -> Output {
        var cancellable: AnyCancellable?
        
        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            
            cancellable = sink(
                receiveCompletion: { completion in
                    guard !didResume else { return }
                    
                    if case let .failure(error) = completion {
                        didResume = true
                        continuation.resume(throwing: error)
                        cancellable?.cancel()
                        cancellable = nil
                    }
                },
                receiveValue: { output in
                    guard !didResume else { return }
                    
                    didResume = true
                    continuation.resume(returning: output)
                    cancellable?.cancel()
                    cancellable = nil
                }
            )
        }
    }
}

extension Publisher where Failure == Never {
    func async() async -> Output {
        var cancellable: AnyCancellable?

        return await withCheckedContinuation { continuation in
            var didResume = false

            cancellable = sink { output in
                guard !didResume else { return }

                didResume = true
                continuation.resume(returning: output)
                cancellable?.cancel()
                cancellable = nil
            }
        }
    }
}
