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
        case profileUpdated(RecruitProfile)
    }

    // MARK: - State
    private(set) var profile: RecruitProfile?
    private(set) var isLoading = false
    private(set) var didLoad = false
    private(set) var errorMessage: String?

    // MARK: - UseCase
    private let fetchMyRecruitProfileUseCase: FetchMyRecruitProfileUseCase

    // MARK: - Initializer
    init(fetchMyRecruitProfileUseCase: FetchMyRecruitProfileUseCase) {
        self.fetchMyRecruitProfileUseCase = fetchMyRecruitProfileUseCase
    }

    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .didAppear:
            fetchMyProfile()
        case .didShowToast:
            errorMessage = nil
        case let .profileUpdated(profile):
            self.profile = profile
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
                profile = try await fetchMyRecruitProfileUseCase.execute()
                didLoad = true
            } catch {
                errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}
