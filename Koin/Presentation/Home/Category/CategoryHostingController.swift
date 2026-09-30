//
//  CategoryHostingController.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI
import UIKit
import SafariServices

@MainActor
final class CategoryHostingController: UIHostingController<CategoryView>, HostingControllerProtocol {
    
    // MARK: - Initializer
    override init(rootView: CategoryView) {
        super.init(rootView: rootView)
        view.backgroundColor = .appColor(.newBackground)
        view.isOpaque = true
        bindAction(to: rootView)
    }
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func execute(action: RootView.Action) {
        switch action {
        case .showTimetable:
            navigationController?.pushViewController(makeTimeTableViewController(), animated: true)
        case .showLostItem:
            navigationController?.pushViewController(makeLostItemListViewController(), animated: true)
        case .showFacility:
            navigationController?.pushViewController(makeFacilityViewController(), animated: true)
        case .showDepartment:
            navigationController?.pushViewController(makeDepartmentCategoryController(), animated: true)
        case .showDining:
            navigationController?.pushViewController(makeDiningViewController(), animated: true)
        case .showShop:
            navigationController?.pushViewController(makeShopViewController(), animated: true)
        case .showBusTimetable:
            navigationController?.pushViewController(makeBusTimetableViewController(), animated: true)
        case .showBusRoute:
            navigationController?.pushViewController(makeBusSearchViewController(), animated: true)
        case .showCallVan:
            navigationController?.pushViewController(makeCallVanListViewController(), animated: true)
        case .showChatList:
            navigationController?.pushViewController(makeChatListViewController(), animated: true)
        case .showLand:
            navigationController?.pushViewController(makeLandViewController(), animated: true)
        case .showBusiness:
            presentBusiness()
        case .showRecruit:
            navigationController?.pushViewController(makeRecruitListViewController(), animated: true)
            
        case .showLoginToast:
            showToastMessageWithButton(
                message: "로그인이 필요한 기능입니다.",
                buttonTitle: "로그인"
            ) { [weak self] in
                self?.navigateToLogin()
            }
        }
    }
}

extension CategoryHostingController {
    private func makeTimeTableViewController() -> UIViewController {
        return TimetableViewController(viewModel: TimetableViewModel())
    }

    private func makeLostItemListViewController() -> UIViewController {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let fetchLostItemListUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let fetchMyKeywordUseCase = DefaultFetchLostItemMyKeywordUseCase(repository: lostItemRepository)
        let viewModel = LostItemListViewModel(
            checkLoginUseCase: checkLoginUseCase,
            fetchLostItemListUseCase: fetchLostItemListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            fetchMyKeywordUseCase: fetchMyKeywordUseCase
        )
        return LostItemListViewController(viewModel: viewModel)
    }

    private func makeFacilityViewController() -> UIViewController {
        return FacilityInfoViewController()
    }

    private func makeDepartmentCategoryController() -> UIViewController {
        let repository = DefaultDepartmentRepository(service: DefaultDepartmentService())
        let searchDepartmentUseCase = DefaultSearchDepartmentUseCase(repository: repository)
        let fetchDepartmentCategoryUseCase = DefaultFetchDepartmentCategoryUseCase(repository: repository)
        let viewModel = DepartmentCategoryViewModel(
            fetchDepartmentCategoryUseCase: fetchDepartmentCategoryUseCase,
            searchDepartmentUseCase: searchDepartmentUseCase
        )
        let rootView = DepartmentCategoryView(viewModel: viewModel)
        return DepartmentCategoryHostingController(rootView: rootView)
    }
    
    private func makeDiningViewController() -> UIViewController {
        let diningService = DefaultDiningService()
        let shareService = KakaoShareService()
        let diningRepository = DefaultDiningRepository(diningService: diningService, shareService: shareService)
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let dateProvider = DefaultDateProvider()
        let shareMenuListUseCase = DefaultShareMenuListUseCase(diningRepository: diningRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase)
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
    
    private func makeChatListViewController() -> UIViewController {
        return LostItemChatListTableViewController(viewModel: LostItemChatListTableViewModel())
    }

    private func makeLandViewController() -> UIViewController {
        let landService = DefaultLandService()
        let landRepository = DefaultLandRepository(service: landService)
        let fetchLandListUseCase = DefaultFetchLandListUseCase(landRepository: landRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = LandViewModel(fetchLandListUseCase: fetchLandListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        return LandViewController(viewModel: viewModel)
    }
    
    private func makeRecruitListViewController() -> UIViewController {
        let recruitRepository = MockRecruitRepository()
        let fetchRecruitListUseCase = DefaultFetchRecruitListUseCase(repository: recruitRepository)
        let fetchRecruitNotificationListUseCase = DefaultFetchRecruitNotificationListUseCase(repository: recruitRepository)
        let viewModel = RecruitListViewModel(
            fetchRecruitListUseCase: fetchRecruitListUseCase,
            fetchRecruitNotificationListUseCase: fetchRecruitNotificationListUseCase
        )
        let rootView = RecruitListView(viewModel: viewModel)
        return RecruitListHostingController(rootView: rootView)
    }

    private func presentBusiness() {
        if let url = URL(string: "https://owner.koreatech.in/") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
        }
    }
}
