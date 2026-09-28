//
//  RecruitMyPostViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RecruitMyPostViewModel: SwiftUIViewModelProtocol {

    enum Input {
        case onFirstAppear
        case didShowToast
    }

    // MARK: - State
    private(set) var data: RecruitMyPostSummary?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Properties
    private let recruitId: Int
    private let fetchRecruitMyPostUseCase: FetchRecruitMyPostUseCase

    // MARK: - Initializer
    init(
        fetchRecruitMyPostUseCase: FetchRecruitMyPostUseCase,
        recruitId: Int
    ) {
        self.fetchRecruitMyPostUseCase = fetchRecruitMyPostUseCase
        self.recruitId = recruitId
    }

    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear:
            fetchRecruitMyPost()
        case .didShowToast:
            errorMessage = nil
        }
    }
}

extension RecruitMyPostViewModel {
    private func fetchRecruitMyPost() {
        guard !isLoading else {
            return
        }

        Task {
            isLoading = true
            defer {
                isLoading = false
            }

            do {
                let data = try await fetchRecruitMyPostUseCase.execute(id: recruitId)
                try Task.checkCancellation()
                self.data = data
            } catch is CancellationError {
                return
            } catch {
                errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}
