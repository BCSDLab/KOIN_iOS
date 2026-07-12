//
//  ProfileViewModel.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import Foundation
import Combine

@Observable
final class ProfileViewModel: SwiftUIViewModelProtocol {
    
    // MARK: - Input
    enum Input {
        case viewDidAppear
        case logout
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - Properties
    private(set) var userInfo: UserDto? = nil
    private(set) var lectures: [LectureData] = []
    
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let deleteDeviceTokenUseCase: DeleteDeviceTokenUseCase
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initiailizer
    init(
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        deleteDeviceTokenUseCase: DeleteDeviceTokenUseCase,
        fetchUserDataUseCase: FetchUserDataUseCase
    ) {
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.deleteDeviceTokenUseCase = deleteDeviceTokenUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
    }
    
    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .viewDidAppear:
            fetchUserInfo()
            fetchTimeTable()
        case let .logEvent(label, category, value):
            makeLogAnalyticsEvent(label: label, category: category, value: value)
        case .logout:
            logout()
        }
    }
}

extension ProfileViewModel {
    
    private func fetchUserInfo() {
        fetchUserDataUseCase.execute().sink(
            receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.userInfo = nil
                    self?.lectures.removeAll()
                }
            },
            receiveValue: { [weak self] response in
                self?.userInfo = response
            }
        ).store(in: &subscriptions)
    }
    
    private func fetchTimeTable() {} // TODO: - API
    
    private func logout() {
        deleteDeviceTokenUseCase.execute().replaceError(with: ()).sink { [weak self] in
            guard let self else { return }
            KeychainWorker.shared.delete(key: .access)
            KeychainWorker.shared.delete(key: .refresh)
            UserDataManager.shared.resetUserData()
            userInfo = nil
            lectures.removeAll()
        }.store(in: &subscriptions)
    }
}

extension ProfileViewModel {
    
    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
