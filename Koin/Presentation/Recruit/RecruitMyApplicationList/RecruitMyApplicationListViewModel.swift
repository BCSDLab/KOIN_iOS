//
//  RecruitMyApplicationListViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation
import Observation

@Observable
final class RecruitMyApplicationListViewModel: SwiftUIViewModelProtocol {

    enum Input {
        case onFirstAppear
        case refresh
        case updateFilter(RecruitMyApplicationFilter)
        case loadNextPage
        case didShowToast
    }

    // MARK: - State
    private(set) var recruitList: RecruitMyApplicationList?
    private(set) var filterState = RecruitMyApplicationFilter()
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Properties
    private let fetchRecruitMyApplicationListUseCase: FetchRecruitMyApplicationListUseCase

    var recruits: [RecruitMyApplicationRow] {
        recruitList?.recruits ?? []
    }

    // MARK: - Initializer
    init(fetchRecruitMyApplicationListUseCase: FetchRecruitMyApplicationListUseCase) {
        self.fetchRecruitMyApplicationListUseCase = fetchRecruitMyApplicationListUseCase
    }

    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear:
            fetchList()
        case .refresh:
            fetchList()
        case .updateFilter(let filter):
            updateFilter(filter)
        case .loadNextPage:
            loadNextPage()
        case .didShowToast:
            errorMessage = nil
        }
    }
}

extension RecruitMyApplicationListViewModel {
    private func updateFilter(_ filter: RecruitMyApplicationFilter) {
        var filter = filter
        filter.page = 1
        filterState = filter
        fetchList()
    }

    private func loadNextPage() {
        guard let recruitList else {
            return
        }
        fetchList(page: recruitList.currentPage + 1)
    }
}

extension RecruitMyApplicationListViewModel {
    private func fetchList(page: Int = 1) {
        guard !isLoading else {
            return
        }

        Task {
            isLoading = true
            defer {
                isLoading = false
            }

            var filter = filterState
            filter.page = page

            do {
                var response = try await fetchRecruitMyApplicationListUseCase.execute(filter: filter)
                try Task.checkCancellation()

                guard response.currentPage == page else {
                    return
                }

                if page > 1 {
                    response.recruits = (recruitList?.recruits ?? []) + response.recruits
                    response.recruits.removeDuplicates()
                }

                filterState = filter
                recruitList = response
            } catch is CancellationError {
                return
            } catch {
                errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}
