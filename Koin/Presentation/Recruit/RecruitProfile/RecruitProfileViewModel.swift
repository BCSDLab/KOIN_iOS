//
//  RecruitProfileViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RecruitProfileViewModel: SwiftUIViewModelProtocol {
    enum Input {
        case didAppear
        case didShowToast
    }

    // MARK: - State
    private(set) var profile: RecruitProfile?
    private(set) var isLoading = false
    private(set) var didLoad = false
    private(set) var errorMessage: String?

    // MARK: - UseCase
    private let fetchMyProfileUseCase: FetchMyProfileUseCase

    // MARK: - Initializer
    init(fetchMyProfileUseCase: FetchMyProfileUseCase) {
        self.fetchMyProfileUseCase = fetchMyProfileUseCase
    }

    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .didAppear:
            fetchMyProfile()
        case .didShowToast:
            errorMessage = nil
        }
    }
}

extension RecruitProfileViewModel {
    private func fetchMyProfile() {
        guard !isLoading else { return }

        Task {
            isLoading = true
            defer {
                isLoading = false
            }

            do {
                profile = try await fetchMyProfileUseCase.execute()
                didLoad = true
            } catch {
                guard let error = error as? ErrorResponse else {
                    return
                }
                if error.statusCode == 404 {
                    profile = nil
                    didLoad = true
                } else {
                    errorMessage = error.message
                }
            }
        }
    }
}
