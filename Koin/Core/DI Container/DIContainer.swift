//
//  Container.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import Foundation

final class DIContainer {
    
    // MARK: - Singleton
    static let shared = DIContainer()
    
    // MARK: - Property
    private var services: [String : Any] = [:]
    
    // MARK: - Initializer
    private init() {
        registerAll()
    }
    
    private func registerAll() {
        register(type: LogAnalyticsEventUseCase.self,
                 component: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
        register(type: AssignAbTestUseCase.self,
                 component: DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService())))
        register(type: GetUserScreenTimeUseCase.self,
                 component: DefaultGetUserScreenTimeUseCase())
    }
}

extension DIContainer {
    
    private func register<T>(type: T.Type, component: T) {
        let key = "\(type)"
        services[key] = component
    }
    
    func resolve<T>(type: T.Type) -> T {
        let key = "\(type)"
        guard let service = services[key] as? T else {
            fatalError("DIContainer cannot resolve \(key) since it has not been registered")
        }
        return service
    }
}
