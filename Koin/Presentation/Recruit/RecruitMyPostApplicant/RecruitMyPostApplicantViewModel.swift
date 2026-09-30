//
//  RecruitMyPostApplicantViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RecruitMyPostApplicantViewModel: SwiftUIViewModelProtocol {

    enum Input {
        case onFirstAppear
        case decide(RecruitApplicationDecision)
        case didShowToast
    }

    // MARK: - State
    private(set) var application: RecruitApplication?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Properties
    let recruitmentId: Int
    private let applicationId: Int
    private let fetchUseCase: FetchRecruitMyPostApplicationUseCase
    private let decideUseCase: DecideRecruitMyPostApplicationUseCase

    // MARK: - Initializer
    init(
        recruitmentId: Int,
        applicationId: Int,
        fetchUseCase: FetchRecruitMyPostApplicationUseCase,
        decideUseCase: DecideRecruitMyPostApplicationUseCase
    ) {
        self.recruitmentId = recruitmentId
        self.applicationId = applicationId
        self.fetchUseCase = fetchUseCase
        self.decideUseCase = decideUseCase
    }

    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear:
            fetchApplication()
        case .decide(let decision):
            decideApplication(decision)
        case .didShowToast:
            errorMessage = nil
        }
    }
}

extension RecruitMyPostApplicantViewModel {
    private func fetchApplication() {
        guard !isLoading else {
            return
        }

        Task {
            isLoading = true
            defer {
                isLoading = false
            }

            do {
                let application = try await fetchUseCase.execute(
                    recruitmentId: recruitmentId,
                    applicationId: applicationId
                )
                self.application = application
            } catch {
                if let error = error as? ErrorResponse {
                    errorMessage = error.message
                } else {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func decideApplication(_ decision: RecruitApplicationDecision) {
        guard !isLoading, let application, application.canDecide else {
            return
        }

        Task {
            isLoading = true
            defer {
                isLoading = false
            }

            do {
                try await decideUseCase.execute(
                    recruitmentId: recruitmentId,
                    applicationId: applicationId,
                    decision: decision
                )
                self.application?.decided(as: decision)
            } catch {
                if let error = error as? ErrorResponse {
                    errorMessage = error.message
                } else {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
