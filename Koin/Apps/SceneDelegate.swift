//
//  SceneDelegate.swift
//  Koin
//
//  Created by 김나훈 on 1/14/24.
//

import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var urlParameters: [String: String]?
    private var subscriptions: Set<AnyCancellable> = []
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
    
        let abTestUseCase = DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService()))
        abTestUseCase.execute(requestModel: AssignAbTestRequest(title: "benefitPage")).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            let viewController = self.selectViewController()
            let navigationController = CustomNavigationController(rootViewController: viewController)
            window.rootViewController = navigationController
            self.window = window
            window.makeKeyAndVisible()
        }.store(in: &subscriptions)
        
        
        
        // URL 처리
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        handleIncomingURL(urlContext.url)
    }
    
    private func selectViewController() -> UIViewController {
        let diningRepository = DefaultDiningRepository(diningService: DefaultDiningService(), shareService: KakaoShareService())
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let fetchShopCategoryUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let dateProvider = DefaultDateProvider()
        
        let homeViewModel = HomeViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase, fetchBusInformationListUseCase: DefaultFetchBusInformationListUseCase(busRepository: DefaultBusRepository(service: DefaultBusService())), dateProvder: dateProvider, fetchShopCategoryListUseCase: fetchShopCategoryUseCase)

        let userType = KeyChainWorker.shared.read(key: .variableName) ?? "a"
        let variableName = UserAssignType(rawValue: userType) ?? .a
        let mainViewController: UIViewController
        switch variableName {
  //      case .a: mainViewController = HomeViewControllerA(viewModel: homeViewModel)
        default: mainViewController = HomeViewControllerB(viewModel: homeViewModel)
        }
        
        return mainViewController
    }
    
    private func handleIncomingURL(_ url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            var parameters: [String: String] = [:]
            
            components.queryItems?.forEach { queryItem in
                parameters[queryItem.name] = queryItem.value
            }
            
            urlParameters = parameters
            
            if let rootViewController = window?.rootViewController {
                handleURLParameters(parameters, from: rootViewController)
            }
        }
    }
    
    private func handleURLParameters(_ parameters: [String: String], from rootViewController: UIViewController) {
        if let date = parameters["date"], let type = parameters["type"], let place = parameters["place"] {
            navigateToDiningViewController(date: date, type: type, place: place, from: rootViewController)
        }
    }
    
    private func navigateToDiningViewController(date: String, type: String, place: String, from rootViewController: UIViewController) {
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
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, diningLikeUseCase: diningLikeUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase, sharedDiningItem: CurrentDiningTime(date: date.toDateFromYYMMDD() ?? Date(), diningType: DiningType(rawValue: "\(type)") ?? .breakfast))
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"
        
        if let navigationController = rootViewController as? UINavigationController {
            navigationController.pushViewController(diningViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: diningViewController)
            rootViewController.present(navigationController, animated: true, completion: nil)
        }
    }
}
