//
//  CategoryViewModel.swift
//  koin
//
//  Created by 홍기정 on 6/7/26.
//

import Foundation
import Observation
import Combine

@Observable
@MainActor
final class CategoryViewModel: SwiftUIViewModelProtocol {
    enum Input {
        case checkAuth
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }

    private let checkLoginUseCase: CheckLoginUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private(set) var isLoggedIn: Bool = false
    private var subscriptions = Set<AnyCancellable>()
        

    init(
        checkLoginUseCase: CheckLoginUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.checkLoginUseCase = checkLoginUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }

    func execute(_ input: Input) {
        switch input {
        case .checkAuth:
            checkLoginUseCase.execute().sink { [weak self] isLoggedIn in
                self?.isLoggedIn = isLoggedIn
            }.store(in: &subscriptions)
        case let .logEvent(label, category, value):
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
}
