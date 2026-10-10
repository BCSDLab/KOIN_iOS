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
        case decide(RecruitApplicantDecision)
        case didShowToast
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }

    // MARK: - State
    private(set) var application: RecruitApplicantData?
    private(set) var isLoading = false
    private(set) var toastMessage: String?

    // MARK: - Properties
    let recruitmentId: Int
    private let applicationId: Int
    private let fetchUseCase: FetchRecruitApplicantUseCase
    private let decideUseCase: DecideRecruitApplicantUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase

    // MARK: - Initializer
    init(
        recruitmentId: Int,
        applicationId: Int,
        fetchUseCase: FetchRecruitApplicantUseCase,
        decideUseCase: DecideRecruitApplicantUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.recruitmentId = recruitmentId
        self.applicationId = applicationId
        self.fetchUseCase = fetchUseCase
        self.decideUseCase = decideUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }

    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear:
            fetchApplication()
        case .decide(let decision):
            decideApplication(decision)
        case .didShowToast:
            toastMessage = nil
        case let .logEvent(label, category, value):
            makeLogAnalyticsEvent(label: label, category: category, value: value)
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
                toastMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }

    private func decideApplication(_ decision: RecruitApplicantDecision) {
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
                toastMessage = "지원자를 \(decision.rawValue)했어요."
            } catch {
                toastMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}

extension RecruitMyPostApplicantViewModel {
    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(
            label: label,
            category: category,
            value: value
        )
    }
}
