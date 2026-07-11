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
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
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
        case .showLand:
            navigationController?.pushViewController(makeLandViewController(), animated: true)
        case .showBusiness:
            presentBusiness()
        }
    }
}

extension CategoryHostingController {
    
    private func configureNavigationBar() {
        configureNavigationBar(style: .order)
        configureLeftBarItem()
        configureRightBarButton()
    }

    private func configureLeftBarItem() {
        let leftBarButtonStackView = UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 0
        }
        leftBarButtonStackView.addArrangedSubview(UIImageView(image: .appImage(asset: .bcsdSymbolLogo)?.resize(to: .init(width: 46, height: 37))))
        leftBarButtonStackView.addArrangedSubview(UIImageView(image: .appImage(asset: .koinTextLogo)?.resize(to: .init(width: 51, height: 30))))
        leftBarButtonStackView.snp.makeConstraints {
            $0.height.equalTo(37)
        }
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonStackView)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    private func configureRightBarButton(hasDot: Bool = false) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .appImage(asset: hasDot ? .homeBellDot : .homeBell)?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(rightBarButtonTapped)
        )
    }

    @objc private func rightBarButtonTapped() {
        rootView.makeLogAnalyticsEvent(
            label: EventParameter.EventLabel.Campus.notification,
            category: .click,
            value: "알림 아이콘")
        navigateToNotification()
    }
     
    private func navigateToNotification() {
        let notificatioHistoryRepository = DefaultNotificationHistoryRepository(service: DefaultNotificationHistoryService())
        let fetchNotificationHistoryUseCase = DefaultFetchNotificationHistoryUseCase(notificationHistoryRepository: notificatioHistoryRepository)
        let deleteNotificationHistoryUseCase = DefaultDeleteNotificationHistoryUseCase(repository: notificatioHistoryRepository)
        let updateNotificationHistoryUseCase = DefaultUpdateNotificationHistoryUseCase(repository: notificatioHistoryRepository)
        
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NotificationViewModel(
            fetchNotificationHistoryUseCase: fetchNotificationHistoryUseCase,
            deleteNotificationHistoryUseCase: deleteNotificationHistoryUseCase,
            updateNotificationHistoryUseCase: updateNotificationHistoryUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let viewController = NotificationViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
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

    private func makeLandViewController() -> UIViewController {
        let landService = DefaultLandService()
        let landRepository = DefaultLandRepository(service: landService)
        let fetchLandListUseCase = DefaultFetchLandListUseCase(landRepository: landRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = LandViewModel(fetchLandListUseCase: fetchLandListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        return LandViewController(viewModel: viewModel)
    }

    private func presentBusiness() {
        if let url = URL(string: "https://owner.koreatech.in/") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
        }
    }
}
