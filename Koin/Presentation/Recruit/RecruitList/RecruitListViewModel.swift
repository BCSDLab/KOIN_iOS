//
//  RecruitListViewModel.swift
//  koin
//
//  Created by 홍기정 on 8/28/26.
//

import Foundation
import Observation

@Observable
final class RecruitListViewModel: SwiftUIViewModelProtocol {
    
    enum Input {
        case onFirstAppear
        case onAppear
        case refresh
        case updateFilter(keyword: String? = nil, filterState: RecruitListFilter? = nil)
        case deleteFilter(rawvalue: String)
        case resetFilter
        case loadNextPage
        case delete(id: Int)
        case didShowToast
    }
    
    // MARK: - State
    private(set) var recruitList: RecruitList?
    private(set) var filterState = RecruitListFilter()
    private(set) var isLoading: Bool = false
    private(set) var hasUnreadNotification: Bool = false
    private(set) var errorMessage: String? = nil
    private var fetchListTask: Task<Void, Never>?
    
    var isEmpty: Bool {
        if let recruitList {
            recruitList.totalCount == 0
        } else {
            true
        }
    }
    var currentPage: Int {
        recruitList?.currentPage ?? 0
    }
    var totalPage: Int {
        recruitList?.totalPage ?? 0
    }
    var hasNextPage: Bool {
        currentPage < totalPage
    }
    
    // MARK: - UseCase
    private let fetchRecruitListUseCase: FetchRecruitListUseCase
    private let fetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase
    
    // MARK: - Initializer
    init(
        fetchRecruitListUseCase: FetchRecruitListUseCase,
        fetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase
    ) {
        self.fetchRecruitListUseCase = fetchRecruitListUseCase
        self.fetchRecruitNotificationListUseCase = fetchRecruitNotificationListUseCase
    }
    
    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear:
            fetchList()
        case .onAppear:
            fetchHasUnreadNotification()
        case .refresh:
            fetchList()
            fetchHasUnreadNotification()
        case .updateFilter(let keyword, let filterState):
            updateFilter(keyword, filterState)
        case .deleteFilter(let rawvalue):
            deleteFilter(rawvalue)
        case .resetFilter:
            resetFilter()
        case .loadNextPage:
            loadNextPage()
        case .delete(let id):
            recruitList?.delete(id: id)
        case .didShowToast:
            errorMessage = nil
        }
    }
}

extension RecruitListViewModel {
    private func updateFilter(
        _ keyword: String?,
        _ filterState: RecruitListFilter?
    ) {
        defer {
            isLoading = false
            fetchList()
        }
        if let keyword {
            self.filterState.keyword = keyword
        } else if let filterState {
            var filterState = filterState
            filterState.keyword = self.filterState.keyword
            self.filterState = filterState
        }
    }
    
    private func deleteFilter(_ rawValue: String) {
        defer {
            isLoading = false
            fetchList()
        }
        filterState.remove(item: rawValue)
    }
    
    private func loadNextPage() {
        fetchList(page: currentPage + 1)
    }
    
    private func resetFilter() {
        defer {
            isLoading = false
            fetchList()
        }
        let keyword = filterState.keyword
        filterState = .init(keyword: keyword)
    }
}

extension RecruitListViewModel {
    private func fetchList(page: Int = 1) {
        guard !isLoading else {
            return
        }
        fetchListTask?.cancel()
        fetchListTask = Task {
            do {
                isLoading = true
                defer {
                    isLoading = false
                }
                
                let cachedPage = filterState.page
                filterState.page = page
                var response = try await fetchRecruitListUseCase.execute(filter: filterState)
                
                guard response.currentPage == page else {
                    filterState.page = cachedPage
                    return
                }
                
                if 1 < page {
                    response.recruits = (recruitList?.recruits ?? []) + response.recruits
                    response.recruits.removeDuplicates()
                }
                self.recruitList = response
            } catch {
                errorMessage = (error as? ErrorResponse)?.message
            }
        }
    }
    
    private func fetchHasUnreadNotification() {
        Task {
            do {
                self.hasUnreadNotification = try await fetchRecruitNotificationListUseCase.execute().hasUnread
            } catch {
                if let error = (error as? ErrorResponse),
                   error.statusCode != 401 {
                    self.errorMessage = error.message
                }
            }
        }
    }
}
