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
        case viewDidAppear
        case refresh
        case updateFilter(keyword: String? = nil, filterState: RecruitListFilter? = nil)
        case deleteFilter(rawvalue: String)
        case resetFilter
        case loadNextPage
        
        case didShowToast
    }
    
    // MARK: - State
    private(set) var recruitList: RecruitList?
    private(set) var filterState = RecruitListFilter()
    private(set) var isLoading: Bool = false
    private(set) var hasUnreadNotification: Bool = false
    private(set) var errorMessage: String? = nil
    
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
    private let fetchListUseCase: FetchRecruitListUseCase
    private let fetchNotificationListUseCase: FetchRecruitNotificationListUseCase
    
    // MARK: - Initializer
    init(
        fetchRecruitListUseCase: FetchRecruitListUseCase,
        fetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase
    ) {
        self.fetchListUseCase = fetchRecruitListUseCase
        self.fetchNotificationListUseCase = fetchRecruitNotificationListUseCase
    }
    
    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .viewDidAppear, .refresh:
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
        if let keyword {
            self.filterState.keyword = keyword
            fetchList()
        } else if let filterState {
            var filterState = filterState
            filterState.keyword = self.filterState.keyword
            self.filterState = filterState
            fetchList()
        }
    }
    
    private func deleteFilter(_ rawValue: String) {
        filterState.remove(item: rawValue)
        fetchList()
    }
    
    private func loadNextPage() {
        fetchList(page: currentPage + 1)
    }
    
    private func resetFilter() {
        filterState = .init()
        fetchList()
    }
}

extension RecruitListViewModel {
    private func fetchList(page: Int = 1) {
        guard !isLoading else {
            return
        }
        Task {
            do {
                isLoading = true
                defer {
                    isLoading = false
                }
                
                filterState.page = page
                var response = try await fetchListUseCase.execute(filter: filterState)
                
                response.recruits = (recruitList?.recruits ?? []) + response.recruits
                response.recruits.removeDuplicates()
                
                self.recruitList = response
            } catch {
                errorMessage = (error as? ErrorResponse)?.message
            }
        }
    }
    
    private func fetchHasUnreadNotification() {
        Task {
            do {
                self.hasUnreadNotification = try await fetchNotificationListUseCase.execute().hasUnread
            } catch {
                if let error = (error as? ErrorResponse),
                   error.statusCode != 401 {
                    self.errorMessage = error.message
                }
            }
        }
    }
}
