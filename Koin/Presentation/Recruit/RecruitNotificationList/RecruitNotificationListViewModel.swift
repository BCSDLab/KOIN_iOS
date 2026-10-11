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
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    enum Output {
        case updateNotifications(RecruitNotificationList)
        case showToast(String)
        case didFinishLoading
        case tapNotification(id: Int)
    }
    
    // MARK: - Properties
    private let fetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase
    private let markAsReadRecruitNotificationUseCase: MarkAsReadRecruitNotificationUseCase
    private let deleteRecruitNotificationUseCase: DeleteRecruitNotificationUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var notificationList: RecruitNotificationList?
    private var isLoading = false
    private var notificationId: Int?

    // MARK: - Initializer
    init(
        fetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase,
        markAsReadRecruitNotificationUseCase: MarkAsReadRecruitNotificationUseCase,
        deleteRecruitNotificationUseCase: DeleteRecruitNotificationUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        notificationId: Int? = nil
    ) {
        self.fetchRecruitNotificationListUseCase = fetchRecruitNotificationListUseCase
        self.markAsReadRecruitNotificationUseCase = markAsReadRecruitNotificationUseCase
        self.deleteRecruitNotificationUseCase = deleteRecruitNotificationUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.notificationId = notificationId
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
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
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
        Task {
            defer {
                isLoading = false
            }
            do {
                guard try await fetchPage(page) else {
                    return
                }
                try await searchNotificationIfNeeded()
            } catch {
                notificationId = nil
                let errorMessage = (error as? ErrorResponse)?.message ?? error.localizedDescription
                outputSubject.send(.showToast(errorMessage))
                outputSubject.send(.didFinishLoading)
            }
        }
    }
    
    /// 한 페이지를 조회해 기존 목록에 이어붙인다. 응답 페이지가 요청과 다르면 false.
    private func fetchPage(_ page: Int) async throws -> Bool {
        var response = try await fetchRecruitNotificationListUseCase.execute(page: page)
        guard response.currentPage == page else {
            return false
        }
        if page > 1 {
            response.notifications = (notificationList?.notifications ?? []) + response.notifications
            response.notifications.removeDuplicates()
        }
        notificationList = response
        outputSubject.send(.updateNotifications(response))
        return true
    }
    
    /// 푸시알림으로 진입한 경우, notificationId 와 일치하는 알림을 찾을 때까지 다음 페이지를 호출한다.
    private func searchNotificationIfNeeded() async throws {
        guard let notificationId else {
            return
        }
        defer {
            self.notificationId = nil
        }
        while let notificationList {
            if notificationList.notifications.contains(where: { $0.id == notificationId }) {
                outputSubject.send(.tapNotification(id: notificationId))
                return
            }
            guard notificationList.hasNextPage,
                  try await fetchPage(notificationList.currentPage + 1) else {
                return
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
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
