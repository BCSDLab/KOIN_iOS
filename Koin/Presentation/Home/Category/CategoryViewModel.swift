//
//  CategoryViewModel.swift
//  koin
//
//  Created by 홍기정 on 6/7/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class CategoryViewModel: SwiftUIViewModelProtocol {
    enum Input {
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }

    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase

    init(logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }

    func execute(_ input: Input) {
        switch input {
        case let .logEvent(label, category, value):
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
}
