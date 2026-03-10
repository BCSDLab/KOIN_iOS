//
//  CallVanReportViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import Foundation
import Combine

final class CallVanReportViewModel: ViewModelProtocol {
    
    enum Input {
        case updateReasonCode(CallVanReportRequestReasonCode)
        case updateCustomReason(String?)
    }
    enum Output {
        case validateNextButton(Bool)
    }
    
    // MARK: - Properties
    private var reportRequest: CallVanReportRequest
    private var reportReason: CallVanReportRequestReason = CallVanReportRequestReason()
    private var context: String?
    private var urlImages: [String] = []
    enum CodingKeys: String, CodingKey {
        case reportedUserId = "reported_user_id"
        case reasons
    }

    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case let .updateReasonCode(reasonCode):
                reportReason.reasonCode = reasonCode
                validate()
            case let .updateCustomReason(customReason):
                reportReason.customReason = customReason
                validate()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialzier
    init(reportedUserId: Int) {
        self.reportRequest = CallVanReportRequest(reportedUserId: reportedUserId, reasons: [])
    }
}

extension CallVanReportViewModel {
    
    private func validate() {
        let validation: Bool
        switch reportReason.reasonCode {
        case .other:
            if let customReason = reportReason.customReason {
                validation = reportReason.reasonCode == .other && customReason.count != 0
            } else {
                validation = false
            }
        case .noShow, .nonPayment, .profanity:
            validation = (reportReason.reasonCode != nil && reportReason.reasonCode != .other)
        default:
            validation = false
        }
        print(reportReason.reasonCode == .other)
        print(reportReason.customReason?.count != 0)
        print(reportReason.customReason ?? "nil")
        
        outputSubject.send(.validateNextButton(validation))
    }
}
