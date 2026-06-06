//
//  NewHomeViewModel.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import Combine
import Foundation
import Observation

@Observable
@MainActor
final class NewHomeViewModel: SwiftUIViewModelProtocol {
    enum Input {
        case viewDidLoad
        case refresh
        case markToastPresented
    }

    var header: HomeHeader = HomeHeader.empty()
    var diningItems: [HomeDiningItem] = []
    var callVanRecruitingCount: Int = 0
    var eventCount: Int = 0
    var openShopCount: Int = 0
    var totalShopCount: Int = 0
    var isLoading: Bool = false
    var toastMessage: String?
    var forceUpdateVersion: String?
    var forceModifyUserRequired = false

    private let fetchHomeHeaderUseCase: FetchHomeHeaderUseCase
    private let fetchHomeDiningListUseCase: FetchHomeDiningListUseCase
    private let fetchCountsUseCase: FetchNewHomeCountsUseCase
    private let checkVersionUseCase: CheckVersionUseCase
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase
    private var subscriptions: Set<AnyCancellable> = []

    init(
        fetchHomeHeaderUseCase: FetchHomeHeaderUseCase,
        fetchHomeDiningListUseCase: FetchHomeDiningListUseCase,
        fetchCountsUseCase: FetchNewHomeCountsUseCase,
        checkVersionUseCase: CheckVersionUseCase,
        fetchUserDataUseCase: FetchUserDataUseCase,
        sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase
    ) {
        self.fetchHomeHeaderUseCase = fetchHomeHeaderUseCase
        self.fetchHomeDiningListUseCase = fetchHomeDiningListUseCase
        self.fetchCountsUseCase = fetchCountsUseCase
        self.checkVersionUseCase = checkVersionUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.sendDeviceTokenIfNeededUseCase = sendDeviceTokenIfNeededUseCase
    }

    func execute(_ input: Input) {
        switch input {
        case .viewDidLoad:
            checkVersion()
            checkForceModifyUser()
            sendDeviceTokenIfNeeded()
            loadHomeContent()
        case .refresh:
            loadHomeContent()
        case .markToastPresented:
            toastMessage = nil
        }
    }
}

extension NewHomeViewModel {
    
    private func checkVersion() {
        checkVersionUseCase.execute()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] response in
                    if response.0 {
                        self?.forceUpdateVersion = response.1
                    }
                }
            )
            .store(in: &subscriptions)
    }
    
    private func checkForceModifyUser() {
        guard UserDefaults.standard.bool(forKey: "forceModal") == false else { return }
        
        fetchUserDataUseCase.execute()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] userData in
                    UserDataManager.shared.setUserData(userData: userData)
                    guard userData.userType == "STUDENT" else { return }
                    guard userData.name == nil ||
                            userData.phoneNumber == nil ||
                            userData.gender == nil ||
                            userData.major == nil ||
                            userData.studentNumber == nil
                    else { return }
                    
                    UserDefaults.standard.set(true, forKey: "forceModal")
                    self?.forceModifyUserRequired = true
                }
            )
            .store(in: &subscriptions)
    }
    
    private func sendDeviceTokenIfNeeded() {
        sendDeviceTokenIfNeededUseCase.execute()
    }
    
    private func loadHomeContent() {
        isLoading = true
        
        Publishers.Zip3(
            fetchHomeHeaderUseCase.execute(),
            fetchHomeDiningListUseCase.execute(),
            fetchCountsUseCase.execute()
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.toastMessage = error.message
                    self?.isLoading = false
                }
            },
            receiveValue: { [weak self] header, diningItems, counts in
                self?.header = header
                self?.diningItems = diningItems
                self?.callVanRecruitingCount = counts.callVanRecruitingCount
                self?.eventCount = counts.eventCount
                self?.openShopCount = counts.openShopCount
                self?.totalShopCount = counts.totalShopCount
                self?.isLoading = false
            }
        )
        .store(in: &subscriptions)
    }
}
