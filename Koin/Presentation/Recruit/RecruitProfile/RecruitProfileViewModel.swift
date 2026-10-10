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
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }

    // MARK: - State
    private(set) var profile: RecruitProfile?
    private(set) var isLoading = false
    private(set) var didLoad = false
    private(set) var errorMessage: String?

    // MARK: - UseCase
    private let fetchMyRecruitProfileUseCase: FetchMyRecruitProfileUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase

    // MARK: - Initializer
    init(
        fetchMyRecruitProfileUseCase: FetchMyRecruitProfileUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.fetchMyRecruitProfileUseCase = fetchMyRecruitProfileUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
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
        case let .logEvent(label, category, value):
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
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
