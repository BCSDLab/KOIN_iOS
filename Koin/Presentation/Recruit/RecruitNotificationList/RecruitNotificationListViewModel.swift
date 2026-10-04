//
//  RecruitNotificationListViewModel.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import Combine
import Foundation

final class RecruitNotificationListViewModel: ViewModelProtocol {
    
    enum Input {
        case viewDidLoad
        case reload
        case loadNextPage
        case didTapNotification(id: Int)
        case deleteNotification(id: Int)
        case deleteAllNotifications
        case markAllAsRead
    }
    
    enum Output {
        case updateNotifications(RecruitNotificationList)
        case showToast(String)
        case didFinishLoading
    }
    
    // MARK: - Properties
    private let fetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase
    private let markAsReadRecruitNotificationUseCase: MarkAsReadRecruitNotificationUseCase
    private let deleteRecruitNotificationUseCase: DeleteRecruitNotificationUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var notificationList: RecruitNotificationList?
    private var isLoading = false

    // MARK: - Initializer
    init(
        fetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase,
        markAsReadRecruitNotificationUseCase: MarkAsReadRecruitNotificationUseCase,
        deleteRecruitNotificationUseCase: DeleteRecruitNotificationUseCase
    ) {
        self.fetchRecruitNotificationListUseCase = fetchRecruitNotificationListUseCase
        self.markAsReadRecruitNotificationUseCase = markAsReadRecruitNotificationUseCase
        self.deleteRecruitNotificationUseCase = deleteRecruitNotificationUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .receive(on: DispatchQueue.main)
            .sink { [weak self] input in
            switch input {
            case .viewDidLoad, .reload:
                self?.fetchNotificationList(page: 1)
            case .loadNextPage:
                self?.loadNextPage()
            case .didTapNotification(let id):
                self?.notificationList?.markAsRead(id: id)
                self?.markAsRead(id: id)
            case .deleteNotification(let id):
                self?.notificationList?.delete(id: id)
                self?.deleteNotification(id: id)
            case .deleteAllNotifications:
                self?.notificationList?.deleteAll()
                self?.deleteAllNotifications()
            case .markAllAsRead:
                self?.notificationList?.markAllAsRead()
                self?.markAllAsRead()
            }
        }
        .store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

private extension RecruitNotificationListViewModel {
    
    private func loadNextPage() {
        guard let notificationList, notificationList.hasNextPage else {
            return
        }
        fetchNotificationList(page: notificationList.currentPage + 1)
    }
    
    private func fetchNotificationList(page: Int) {
        guard !isLoading else {
            return
        }
        isLoading = true
        Task { @MainActor in
            defer {
                isLoading = false
            }
            do {
                var response = try await fetchRecruitNotificationListUseCase.execute(page: page)
                guard response.currentPage == page else {
                    return
                }
                if page > 1 {
                    let loadedIds = Set(notificationList?.notifications.map(\.id) ?? [])
                    response.notifications = (notificationList?.notifications ?? [])
                        + response.notifications.filter { !loadedIds.contains($0.id) }
                }
                notificationList = response
                outputSubject.send(.updateNotifications(response))
            } catch {
                if let message = (error as? ErrorResponse)?.message {
                    outputSubject.send(.showToast(message))
                }
                outputSubject.send(.didFinishLoading)
            }
        }
    }
    
    private func deleteNotification(id: Int) {
        Task {
            do {
                try await deleteRecruitNotificationUseCase.execute(id: id)
                outputSubject.send(.showToast("알림이 삭제되었습니다."))
            } catch {
                if let message = (error as? ErrorResponse)?.message {
                    outputSubject.send(.showToast(message))
                }
            }
        }
    }
    
    private func deleteAllNotifications() {
        Task {
            do {
                try await deleteRecruitNotificationUseCase.execute(id: nil)
                outputSubject.send(.showToast("알림이 삭제되었습니다."))
            } catch {
                if let message = (error as? ErrorResponse)?.message {
                    outputSubject.send(.showToast(message))
                }
            }
        }
    }
    
    private func markAsRead(id: Int) {
        Task {
            do {
                try await markAsReadRecruitNotificationUseCase.execute(id: id)
            } catch {
                if let message = (error as? ErrorResponse)?.message {
                    outputSubject.send(.showToast(message))
                }
            }
        }
    }
    
    private func markAllAsRead() {
        Task {
            do {
                try await markAsReadRecruitNotificationUseCase.execute(id: nil)
            } catch {
                if let message = (error as? ErrorResponse)?.message {
                    outputSubject.send(.showToast(message))
                }
            }
        }
    }
}
