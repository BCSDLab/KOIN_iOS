//
//  HomeHostingController.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI
import UIKit

@MainActor
final class HomeHostingController: UIHostingController<HomeView>, HostingControllerProtocol {
    typealias RootView = HomeView

    override init(rootView: HomeView) {
        super.init(rootView: rootView)
        view.backgroundColor = .appColor(.newBackground)
        view.isOpaque = true
        bindAction(to: rootView)
    }

    @available(*, unavailable)
    dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func execute(action: RootView.Action) {
        switch action {
        case .showDining:
            navigationController?.pushViewController(makeDiningViewController(), animated: true)
        case .showBusTimetable:
            navigationController?.pushViewController(makeBusTimetableViewController(), animated: true)
        case .showCallVan:
            navigationController?.pushViewController(makeCallVanListViewController(), animated: true)
        case .showBusSearch:
            navigationController?.pushViewController(makeBusSearchViewController(), animated: true)
        case .showQRCode:
            showQRCode()
        case .showShop:
            navigationController?.pushViewController(makeShopViewController(), animated: true)
        case let .showToast(message):
            showToastMessage(message: message)
        case let .showBanner(banner, isLoggedIn):
            showBanner(banner, isLoggedIn: isLoggedIn)
        }
    }
}

extension HomeHostingController {
    private func makeDiningViewController() -> UIViewController {
        let diningService = DefaultDiningService()
        let shareService = KakaoShareService()
        let diningRepository = DefaultDiningRepository(diningService: diningService, shareService: shareService)
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let diningLikeUseCase = DefaultDiningLikeUseCase(diningRepository: diningRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let dateProvider = DefaultDateProvider()
        let shareMenuListUseCase = DefaultShareMenuListUseCase(diningRepository: diningRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, diningLikeUseCase: diningLikeUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase)
        return DiningViewController(viewModel: viewModel)
    }

    private func makeShopViewController() -> UIViewController {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
        let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
        let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let viewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase
        )
        return ShopViewController(viewModel: viewModel)
    }

    private func makeBusTimetableViewController() -> UIViewController {
        let repository = DefaultBusRepository(service: DefaultBusService())
        let viewModel = BusTimetableViewModel(fetchExpressTimetableUseCase: DefaultFetchExpressTimetableUseCase(busRepository: repository), getExpressFiltersUseCase: DefaultGetExpressFilterUseCase(), getCityFiltersUseCase: DefaultGetCityFiltersUseCase(), fetchCityTimetableUseCase: DefaultFetchCityBusTimetableUseCase(busRepository: repository), getShuttleFilterUseCase: DefaultGetShuttleBusFilterUseCase(), fetchShuttleRoutesUseCase: DefaultFetchShuttleBusRoutesUseCase(busRepository: repository), fetchEmergencyNoticeUseCase: DefaultFetchEmergencyNoticeUseCase(repository: repository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
        return BusTimetableViewController(viewModel: viewModel)
    }

    private func makeBusSearchViewController() -> UIViewController {
        let viewModel = BusSearchViewModel(
            selectBusAreaUseCase: DefaultSelectDepartAndArrivalUseCase(),
            fetchEmergencyNoticeUseCase: DefaultFetchEmergencyNoticeUseCase(repository: DefaultBusRepository(service: DefaultBusService())),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        )
        return BusSearchViewController(viewModel: viewModel)
    }

    private func makeCallVanListViewController() -> UIViewController {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let fetchCallVanListUseCase = DefaultFetchCallVanListUseCase(repository: callVanRepository)
        let fetchCallVanNotificationListUseCase = DefaultFetchCallVanNotificationListUseCase(repository: callVanRepository)
        let participateCallVanUseCase = DefaultParticipateCallVanUseCase(repository: callVanRepository)
        let quitCallVanUseCase = DefaultQuitCallVanUseCase(repository: callVanRepository)
        let closeCallVanUseCase = DefaultCloseCallVanUseCase(repository: callVanRepository)
        let reopenCallVanUseCase = DefaultReopenCallVanUseCase(repository: callVanRepository)
        let completeCallVanUseCase = DefaultCompleteCallVanUseCase(repository: callVanRepository)
        let fetchCallVanSummaryUseCase = DefaultFetchCallVanSummaryUseCase(repository: callVanRepository)
        let fetchCallVanRestrictionUseCase = DefaultFetchCallVanRestrictionUseCase(repository: callVanRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewModel = CallVanListViewModel(
            checkLoginUseCase: checkLoginUseCase,
            fetchCallVanListUseCase: fetchCallVanListUseCase,
            fetchCallVanNotificationListUseCase: fetchCallVanNotificationListUseCase,
            participateCallVanUseCase: participateCallVanUseCase,
            quitCallVanUseCase: quitCallVanUseCase,
            closeCallVanUseCase: closeCallVanUseCase,
            reopenCallVanUseCase: reopenCallVanUseCase,
            completeCallVanUseCase: completeCallVanUseCase,
            fetchCallVanSummaryUseCase: fetchCallVanSummaryUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            fetchCallVanRestrictionUseCase: fetchCallVanRestrictionUseCase,
            fetchNotiListUseCase: fetchNotiListUseCase
        )
        return CallVanListViewController(viewModel: viewModel)
    }

    private func showQRCode() {
        if let url = URL(string: "https://koreatech.unibus.kr/#!/qrcode") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - Banner

extension HomeHostingController {
    private func showBanner(_ banner: BannerDto, isLoggedIn: Bool) {
        guard banner.count > 0, !banner.banners.isEmpty else { return }

        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(
            repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
        )
        let bannerViewController = NewBannerViewController(
            onBannerTap: { [weak self] banner in
                self?.handleBannerTap(banner, isLoggedIn: isLoggedIn)
            },
            onLogEvent: { label, category, value in
                logAnalyticsEventUseCase.execute(
                    label: label,
                    category: category,
                    value: value
                )
            }
        )
        bannerViewController.setBanners(banner.banners)

        let bottomSheetViewController = BottomSheetViewController(
            contentViewController: bannerViewController,
            defaultHeight: 341 + UIApplication.bottomSafeAreaHeight()
        )
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        bottomSheetViewController.modalTransitionStyle = .crossDissolve
        logAnalyticsEventUseCase.logEvent(
            name: "CAMPUS",
            label: "main_modal_entry",
            value: banner.banners.first?.title ?? "",
            category: "entry"
        )
        present(bottomSheetViewController, animated: true)
    }

    private func handleBannerTap(_ banner: Banner, isLoggedIn: Bool) {
        dismiss(animated: true)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(
            repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
        )
        logAnalyticsEventUseCase.logEvent(
            name: "CAMPUS",
            label: "main_modal",
            value: banner.title,
            category: "click"
        )

        if let version = banner.version,
           isVersion(currentAppVersion, lowerThan: version) {
            showToast(message: "해당 기능을 사용하기 위해서는 업데이트가 꼭 필요해요")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guard let appStoreURL = URL(string: "https://apps.apple.com/kr/app/%EC%BD%94%EC%9D%B8-koreatech-in-%ED%95%9C%EA%B8%B0%EB%8C%80-%EC%BB%A4%EB%AE%A4%EB%8B%88%ED%8B%B0/id1500848622") else { return }
                UIApplication.shared.open(appStoreURL)
            }
            return
        }

        switch banner.redirectLink {
        case "shop":
            navigationController?.pushViewController(makeShopViewController(), animated: true)
        case "dining":
            navigationController?.pushViewController(makeDiningViewController(), animated: true)
        case "keyword":
            navigationController?.pushViewController(makeManageNoticeKeywordViewController(), animated: true)
        case "timetable":
            guard isLoggedIn else {
                showToast(message: "로그인이 필요한 기능입니다.", success: true)
                return
            }
            navigationController?.pushViewController(
                TimetableViewController(viewModel: TimetableViewModel()),
                animated: true
            )
        case "login":
            navigationController?.pushViewController(makeLoginViewController(), animated: true)
        case "chat":
            guard isLoggedIn else {
                showToast(message: "로그인이 필요한 기능입니다.")
                return
            }
            navigationController?.pushViewController(
                ChatListTableViewController(viewModel: ChatListTableViewModel()),
                animated: true
            )
        case "lostitem":
            navigationController?.pushViewController(makeLostItemListViewController(), animated: true)
        case "home", .none:
            return
        default:
            return
        }
    }

    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    private func isVersion(_ currentVersion: String, lowerThan requiredVersion: String) -> Bool {
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        let requiredComponents = requiredVersion.split(separator: ".").compactMap { Int($0) }

        for index in 0..<max(currentComponents.count, requiredComponents.count) {
            let current = index < currentComponents.count ? currentComponents[index] : 0
            let required = index < requiredComponents.count ? requiredComponents[index] : 0
            if current < required { return true }
            if current > required { return false }
        }
        return false
    }

    private func makeManageNoticeKeywordViewController() -> UIViewController {
        let noticeRepository = DefaultNoticeListRepository(service: DefaultNoticeService())
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let viewModel = ManageNoticeKeywordViewModel(
            addNotificationKeywordUseCase: DefaultAddNotificationKeywordUseCase(noticeListRepository: noticeRepository),
            deleteNotificationKeywordUseCase: DefaultDeleteNotificationKeywordUseCase(noticeListRepository: noticeRepository),
            fetchNotificationKeywordUseCase: DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeRepository),
            fetchRecommendedKeywordUseCase: DefaultFetchRecommendedKeywordUseCase(noticeListRepository: noticeRepository),
            changeNotiUseCase: DefaultChangeNotiUseCase(notiRepository: notiRepository),
            fetchNotiListUseCase: DefaultFetchNotiListUseCase(notiRepository: notiRepository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
            )
        )
        return ManageNoticeKeywordViewController(viewModel: viewModel)
    }

    private func makeLoginViewController() -> UIViewController {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let viewModel = LoginViewModel(
            loginUseCase: DefaultLoginUseCase(userRepository: userRepository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
            ),
            fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: userRepository),
            sendDeviceTokenIfNeededUseCase: DefaultSendDeviceTokenIfNeededUseCase(
                userRepository: userRepository,
                notiRepository: DefaultNotiRepository(service: DefaultNotiService())
            )
        )
        return LoginViewController(viewModel: viewModel)
    }

    private func makeLostItemListViewController() -> UIViewController {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let viewModel = LostItemListViewModel(
            checkLoginUseCase: DefaultCheckLoginUseCase(userRepository: userRepository),
            fetchLostItemListUseCase: DefaultFetchLostItemListUseCase(repository: lostItemRepository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
            ),
            fetchMyKeywordUseCase: DefaultFetchLostItemMyKeywordUseCase(repository: lostItemRepository)
        )
        return LostItemListViewController(viewModel: viewModel)
    }
}
