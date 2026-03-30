//
//  NotificationHandler.swift
//  koin
//
//  Created by 김나훈 on 12/3/24.
//

import Foundation
import UIKit

final class NotificationHandler {
    static let shared = NotificationHandler()
    
    private init() {}
    
    // MARK: - 카카오톡 딥링크 처리
    func handleIncomingURL(url: URL, navigationController: UINavigationController?) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        
        var parameters: [String: String] = [:]
        components.queryItems?.forEach { queryItem in
            parameters[queryItem.name] = queryItem.value
        }
        
        if let date = parameters["date"], let type = parameters["type"], let place = parameters["place"] {
            handleDiningNavigation(date: date, type: type, place: place, navigationController: navigationController)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.menuShare, category: .click, value: "코인으로 이동")
            return
        }
    }
    
    // MARK: - 푸시알림 처리
    func handleNotificationData(userInfo: [AnyHashable: Any], navigationController: UINavigationController?) {
        guard let aps = userInfo["aps"] as? [String: AnyObject], let category = aps["category"] as? String else {
            print("Invalid notification data")
            return
        }
        switch category {
        case "keyword":
            handleKeywordNotification(userInfo: userInfo, navigationController: navigationController)
        case "dining":
            let diningViewController = createDiningViewController()
            navigationController?.pushViewController(diningViewController, animated: true)
        case "shop":
            let shopViewController = createShopViewController()
            navigationController?.pushViewController(shopViewController, animated: true)
        default:
            return
        }
    }
}

extension NotificationHandler {
    
    private func handleDiningNavigation(date: String, type: String, place: String, navigationController: UINavigationController?) {
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
        let viewModel = DiningViewModel(
            fetchDiningListUseCase: fetchDiningListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            dateProvder: dateProvider,
            shareMenuListUseCase: shareMenuListUseCase,
            diningLikeUseCase: diningLikeUseCase,
            changeNotiUseCase: changeNotiUseCase,
            fetchNotiListUsecase: fetchNotiListUseCase,
            changeNotiDetailUseCase: changeNotiDetailUseCase,
            sharedDiningItem: CurrentDiningTime(date: date.toDateFromYYMMDD() ?? Date(), diningType: DiningType(rawValue: "\(type)") ?? .breakfast)
        )
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"
        
        navigationController?.pushViewController(diningViewController, animated: true)
    }
    
    private func handleKeywordNotification(userInfo: [AnyHashable: Any], navigationController: UINavigationController?) {
        guard let schemeUri = userInfo["schemeUri"] as? String else {
            print("No schemeUri found")
            return
        }
        guard let id = extractValue(from: schemeUri, value: "id"), let intId = Int(id) else {
            print("Invalid or missing ID")
            return
        }
        
        let service = DefaultNoticeService()
        let repository = DefaultNoticeListRepository(service: service)
        let viewModel = NoticeDataViewModel(
            fetchNoticeDataUseCase: DefaultFetchNoticeDataUseCase(noticeListRepository: repository),
            fetchHotNoticeArticlesUseCase: DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository),
            downloadNoticeAttachmentUseCase: DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())),
            noticeId: intId, boardId: -1
        )
        let viewController = NoticeDataViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
        
        if let keyword = extractValue(from: schemeUri, value: "keyword") {
            let logAnalyticsEventUseCase =
            DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: MockAnalyticsService()))
            logAnalyticsEventUseCase.execute(
                label: EventParameter.EventLabel.Campus.keywordNotification,
                category: .notification,
                value: keyword
            )
        }
    }
    
    private func extractValue(from urlString: String, value: String) -> String? {
        let components = URLComponents(string: urlString)
        return components?.queryItems?.first(where: { $0.name == value })?.value
    }
}

extension NotificationHandler {
    
    private func createDiningViewController() -> UIViewController {
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
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"
        return diningViewController
    }
    
    private func createShopViewController() -> UIViewController {
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
            getUserScreenTimeUseCase: getUserScreenTimeUseCase)
        let shopViewController = ShopViewController(viewModel: viewModel)
        shopViewController.title = "주변상점"
        return shopViewController
    }
}
