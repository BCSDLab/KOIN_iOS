//
//  RecruitMyPostListViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation
import Observation

@Observable
final class RecruitMyPostListViewModel: SwiftUIViewModelProtocol {

    enum Input {
        case onFirstAppear
        case refresh
        case updateFilter(RecruitMyPostFilter)
        case loadNextPage
        case close(id: Int)
        case delete(id: Int)
        case didShowToast
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }

    // MARK: - State
    private(set) var recruitList: RecruitMyPostList?
    private(set) var filterState = RecruitMyPostFilter()
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var successMessage: String?

    // MARK: - Properties
    private let fetchRecruitMyPostListUseCase: FetchRecruitMyPostListUseCase
    private let closeRecruitMyPostUseCase: CloseRecruitMyPostUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase

    var recruits: [RecruitMyPostRow] {
        recruitList?.recruits ?? []
    }

    // MARK: - Initializer
    init(
        fetchRecruitMyPostListUseCase: FetchRecruitMyPostListUseCase,
        closeRecruitMyPostUseCase: CloseRecruitMyPostUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.fetchRecruitMyPostListUseCase = fetchRecruitMyPostListUseCase
        self.closeRecruitMyPostUseCase = closeRecruitMyPostUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
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
        case .close(let id):
            close(id: id)
        case .delete(let id):
            recruitList?.delete(id: id)
        case .didShowToast:
            errorMessage = nil
            successMessage = nil
        case let .logEvent(label, category, value):
            makeLogAnalyticsEvent(label: label, category: category, value: value)
        }
    }
}

extension RecruitMyPostListViewModel {
    private func updateFilter(_ filter: RecruitMyPostFilter) {
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

    private func close(id: Int) {
        Task {
            do {
                guard try await closeRecruitMyPostUseCase.execute(id: id) else {
                    return
                }
                recruitList?.delete(id: id)
                successMessage = "모집글을 마감했어요."
            } catch {
                errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}

extension RecruitMyPostListViewModel {
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
                var response = try await fetchRecruitMyPostListUseCase.execute(filter: filter)
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

extension RecruitMyPostListViewModel {
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
