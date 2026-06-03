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
        case let .showForceUpdate(version):
            navigationController?.present(makeForceUpdateViewController(), animated: true)
        case .showForceModifyUser:
            navigationController?.present(makeForceModifyUserViewController(), animated: true)
        case let .showToast(message):
            showToastMessage(message: message)
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

    private func makeForceUpdateViewController() -> UIViewController {
        let viewController = ForceUpdateViewController(
            viewModel: ForceUpdateViewModel(
                logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(
                    repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
                ),
                checkVersionUseCase: DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))
            )
        )
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }

    private func makeForceModifyUserViewController() -> UIViewController {
        return ForceModifyUserViewController()
    }
}
