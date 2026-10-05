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
        case loadNextPage
        case didShowToast
        case refresh
    }

    // MARK: - State
    private(set) var data: RecruitMyPostData?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Properties
    private let recruitId: Int
    private let fetchRecruitMyPostDataUseCase: FetchRecruitMyPostDataUseCase

    // MARK: - Initializer
    init(
        fetchRecruitMyPostDataUseCase: FetchRecruitMyPostDataUseCase,
        recruitId: Int
    ) {
        self.fetchRecruitMyPostDataUseCase = fetchRecruitMyPostDataUseCase
        self.recruitId = recruitId
    }

    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear, .refresh:
            fetchRecruitMyPost()
        case .loadNextPage:
            loadNextPage()
        case .didShowToast:
            errorMessage = nil
        }
    }
}

extension RecruitMyPostViewModel {
    private func loadNextPage() {
        guard let data, data.hasNextPage else {
            return
        }
        fetchRecruitMyPost(page: data.currentPage + 1)
    }

    private func fetchRecruitMyPost(page: Int = 1) {
        guard !isLoading else {
            return
        }

        Task {
            isLoading = true
            defer {
                isLoading = false
            }

            do {
                var response = try await fetchRecruitMyPostDataUseCase.execute(id: recruitId, page: page)
                try Task.checkCancellation()

                guard response.currentPage == page else {
                    return
                }

                if page > 1 {
                    response.applicants = (data?.applicants ?? []) + response.applicants
                    response.applicants.removeDuplicates()
                }
                self.data = response
            } catch is CancellationError {
                return
            } catch {
                errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}
