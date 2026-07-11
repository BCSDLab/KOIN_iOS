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
        case didShowToast
        case didShowBanner
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }

    private(set) var header: HomeHeader = HomeHeader.empty()
    private(set) var diningItems: [HomeDiningItem] = []
    private(set) var callVanRecruitingCount: Int = 0
    private(set) var eventCount: Int = 0
    private(set) var openShopCount: Int = 0
    private(set) var totalShopCount: Int = 0
    private(set) var isLoading: Bool = false
    private(set) var toastMessage: String?
    private(set) var forceUpdateVersion: String?
    private(set) var forceModifyUserRequired = false
    private(set) var bannerToPresent: BannerDto?
    private(set) var isLoggedIn = false

    private let fetchHomeHeaderUseCase: FetchHomeHeaderUseCase
    private let fetchHomeDiningListUseCase: FetchHomeDiningListUseCase
    private let fetchCountsUseCase: FetchNewHomeCountsUseCase
    private let checkVersionUseCase: CheckVersionUseCase
    private let checkLoginUseCase: CheckLoginUseCase
    private let fetchUserDataUseCase: FetchUserDataUseCase
    private let sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchBannerUseCase: FetchBannerUseCase
    private var subscriptions: Set<AnyCancellable> = []

    init(
        fetchHomeHeaderUseCase: FetchHomeHeaderUseCase,
        fetchHomeDiningListUseCase: FetchHomeDiningListUseCase,
        fetchCountsUseCase: FetchNewHomeCountsUseCase,
        checkVersionUseCase: CheckVersionUseCase,
        checkLoginUseCase: CheckLoginUseCase,
        fetchUserDataUseCase: FetchUserDataUseCase,
        sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        fetchBannerUseCase: FetchBannerUseCase
    ) {
        self.fetchHomeHeaderUseCase = fetchHomeHeaderUseCase
        self.fetchHomeDiningListUseCase = fetchHomeDiningListUseCase
        self.fetchCountsUseCase = fetchCountsUseCase
        self.checkVersionUseCase = checkVersionUseCase
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchUserDataUseCase = fetchUserDataUseCase
        self.sendDeviceTokenIfNeededUseCase = sendDeviceTokenIfNeededUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchBannerUseCase = fetchBannerUseCase
    }

    func execute(_ input: Input) {
        switch input {
        case .viewDidLoad:
            checkLogin { [weak self] in
                self?.checkAndFetchBanner()
            }
            checkVersion()
            checkForceModifyUser()
            sendDeviceTokenIfNeeded()
            loadHomeContent()
        case .refresh:
            loadHomeContent()
        case .didShowToast:
            toastMessage = nil
        case .didShowBanner:
            bannerToPresent = nil
        case let .logEvent(label, category, value):
            makeLogAnalyticsEvent(label: label, category: category, value: value)
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

    private func checkLogin(completion: @escaping (() -> Void)) {
        checkLoginUseCase.execute()
            .sink { [weak self] isLoggedIn in
                self?.isLoggedIn = isLoggedIn
                completion()
            }
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

    private func checkAndFetchBanner() {
        if let noShowDate = UserDefaults.standard.object(forKey: "noShowBanner") as? Date,
           let thresholdDate = Calendar.current.date(byAdding: .day, value: 7, to: noShowDate),
           Date() < thresholdDate {
            return
        }

        fetchBannerUseCase.execute()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] banner in
                    guard banner.count > 0, !banner.banners.isEmpty else { return }
                    self?.bannerToPresent = banner
                }
            )
            .store(in: &subscriptions)
    }

    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
