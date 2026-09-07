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
                self?.fetchNotificationList()
            case .didTapNotification(let id):
                self?.markAsRead(id: id)
            case .deleteNotification(let id):
                self?.deleteNotification(id: id)
            case .deleteAllNotifications:
                self?.deleteAllNotifications()
            case .markAllAsRead:
                self?.markAllAsRead()
            }
        }
        .store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

private extension RecruitNotificationListViewModel {
    
    private func fetchNotificationList() {
        Task {
            do {
                let notificationList = try await fetchRecruitNotificationListUseCase.execute()
                outputSubject.send(.updateNotifications(notificationList))
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
