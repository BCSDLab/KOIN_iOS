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
    
    func handleIncomingURL(url: URL, rootViewController: UIViewController?) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        
        var parameters: [String: String] = [:]
        components.queryItems?.forEach { queryItem in
            parameters[queryItem.name] = queryItem.value
        }
        
        if let date = parameters["date"], let type = parameters["type"], let place = parameters["place"] {
            handleDiningNavigation(date: date, type: type, place: place, rootViewController: rootViewController)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.menuShare, category: .click, value: "코인으로 이동")
            return
        }
        
        let pathComponents = url.pathComponents
        if pathComponents.contains("clubs"),
           let clubIdIndex = pathComponents.firstIndex(of: "clubs"),
           clubIdIndex + 1 < pathComponents.count {
            let clubId = pathComponents[clubIdIndex + 1]
            handleClubNavigation(clubId: clubId, tab: parameters["tab"], eventId: parameters["eventId"], rootViewController: rootViewController)
        }
    }
    
    private func handleDiningNavigation(date: String, type: String, place: String, rootViewController: UIViewController?) {
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
            assignAbTestUseCase: DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService())),
            sharedDiningItem: CurrentDiningTime(date: date.toDateFromYYMMDD() ?? Date(), diningType: DiningType(rawValue: "\(type)") ?? .breakfast)
        )
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"

        if let navigationController = rootViewController as? UINavigationController {
            navigationController.pushViewController(diningViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: diningViewController)
            rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    private func handleClubNavigation(clubId: String, tab: String?, eventId: String?, rootViewController: UIViewController?) {
        var parameterString = "/clubs/\(clubId)"
        
        if let tab = tab {
            parameterString += "?tab=\(tab)"
            if let eventId = eventId {
                parameterString += "&eventId=\(eventId)"
            }
        }
        
        let clubWebViewController = ClubWebViewController(parameter: parameterString)
        
        if let navigationController = rootViewController as? UINavigationController {
            navigationController.pushViewController(clubWebViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: clubWebViewController)
            rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func handleNotificationData(userInfo: [AnyHashable: Any], rootViewController: UINavigationController?) {
        guard let aps = userInfo["aps"] as? [String: AnyObject], let category = aps["category"] as? String else {
            print("Invalid notification data")
            return
        }
        switch category {
        case "keyword":
            handleKeywordNotification(userInfo: userInfo, rootViewController: rootViewController)
        default:
            navigateToScene(category: category, rootViewController: rootViewController)
        }
    }
    
    private func handleKeywordNotification(userInfo: [AnyHashable: Any], rootViewController: UINavigationController?) {
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
        let vc = NoticeDataViewController(viewModel: viewModel)
        rootViewController?.pushViewController(vc, animated: true)
        
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
    
    func navigateToScene(category: String, rootViewController: UINavigationController?) {
        switch category {
        case "dining":
            let diningViewController = createDiningViewController()
            rootViewController?.pushViewController(diningViewController, animated: true)
        case "shop":
            let shopViewController = createShopViewController()
            rootViewController?.pushViewController(shopViewController, animated: true)
        default:
            print("Unknown category")
        }
    }
    
    private func extractValue(from urlString: String, value: String) -> String? {
        let components = URLComponents(string: urlString)
        return components?.queryItems?.first(where: { $0.name == value })?.value
    }
    
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
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, diningLikeUseCase: diningLikeUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase, assignAbTestUseCase: DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService())))
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
        let searchShopUseCase = DefaultSearchShopUseCase(shopRepository: shopRepository)
        
        let viewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            searchShopUseCase: searchShopUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            selectedId: 0
        )
        let shopViewController = ShopViewController(viewModel: viewModel)
        shopViewController.title = "주변상점"
        return shopViewController
    }
}
