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
        case updateProfile(RecruitProfile)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - State
    private(set) var recruitList: RecruitList?
    private(set) var filterState = RecruitListFilter()
    private(set) var isLoading: Bool = false
    private(set) var hasUnreadNotification: Bool = false
    private(set) var errorMessage: String? = nil
    private(set) var shouldScrollToTop: Bool = false
    
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
    var canPost: Bool {
        myRecruitProfile != nil
    }
    
    // MARK: - Properties
    private let fetchRecruitListUseCase: FetchRecruitListUseCase
    private let fetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase
    private let fetchMyRecruitProfileUseCase: FetchMyRecruitProfileUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    
    private var fetchListTask: Task<Void, Never>?
    private var myRecruitProfile: RecruitProfile?
    
    // MARK: - Initializer
    init(
        fetchRecruitListUseCase: FetchRecruitListUseCase,
        fetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase,
        fetchMyRecruitProfileUseCase: FetchMyRecruitProfileUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.fetchRecruitListUseCase = fetchRecruitListUseCase
        self.fetchRecruitNotificationListUseCase = fetchRecruitNotificationListUseCase
        self.fetchMyRecruitProfileUseCase = fetchMyRecruitProfileUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear:
            fetchList()
        case .onAppear:
            fetchHasUnreadNotification()
            fetchMyRecruitProfile()
        case .refresh:
            fetchList()
            fetchHasUnreadNotification()
            fetchMyRecruitProfile()
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
        case .updateProfile(let profile):
            myRecruitProfile = profile
        case let .logEvent(label, category, value):
            makeLogAnalyticsEvent(label: label, category: category, value: value)
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
            fetchList(shouldScrollToTop: true)
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
            fetchList(shouldScrollToTop: true)
        }
        filterState.remove(item: rawValue)
    }
    
    private func loadNextPage() {
        fetchList(page: currentPage + 1)
    }
    
    private func resetFilter() {
        defer {
            isLoading = false
            fetchList(shouldScrollToTop: true)
        }
        let keyword = filterState.keyword
        filterState = .init(keyword: keyword)
    }
}

extension RecruitListViewModel {
    private func fetchList(
        page: Int = 1,
        shouldScrollToTop: Bool = false
    ) {
        guard !isLoading else {
            return
        }
        fetchListTask?.cancel()
        fetchListTask = Task {
            do {
                isLoading = true
                self.shouldScrollToTop = false
                
                defer {
                    isLoading = false
                }
                
                let cachedPage = filterState.page
                filterState.page = page
                var response = try await fetchRecruitListUseCase.execute(filter: filterState)
                
                guard !Task.isCancelled, response.currentPage == page else {
                    filterState.page = cachedPage
                    return
                }
                if 1 < page {
                    response.recruits = (recruitList?.recruits ?? []) + response.recruits
                    response.recruits.removeDuplicates()
                }
                self.recruitList = response
                self.shouldScrollToTop = shouldScrollToTop
            } catch {
                errorMessage = (error as? ErrorResponse)?.message
            }
        }
    }
    
    private func fetchHasUnreadNotification() {
        Task {
            do {
                self.hasUnreadNotification = try await fetchRecruitNotificationListUseCase.execute(page: 1).hasUnread
            } catch let error as ErrorResponse where error.statusCode == 401 {
                return
            } catch {
                self.errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}

extension RecruitListViewModel {
    private func fetchMyRecruitProfile() {
        Task {
            do {
                myRecruitProfile = try await fetchMyRecruitProfileUseCase.execute()
            } catch {
                errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
            }
        }
    }
}

extension RecruitListViewModel {
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
