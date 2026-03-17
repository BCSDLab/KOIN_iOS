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
        case updateReasonCode(CallVanReportRequestReasonCode, Bool)
        case updateCustomReason(String?)
        case updateDescription(String?)
        case uploadImage(Data)
        case report([String])
    }
    enum Output {
        case showToast(String)
        case validateNextButton(Bool)
        case apeendImageUrl(String)
        case reportCompleted
    }
    
    // MARK: - Properties
    private let uploadFileUseCase: UploadFileUseCase
    private let reportCallVanUserUseCase: ReportCallVanUserUseCase
    private let postId: Int
    private var reportRequest: CallVanReportRequest
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initialzier
    init(postId: Int,
         reportedUserId: Int,
         uploadFileUseCase: UploadFileUseCase,
         reportCallVanUserUseCase: ReportCallVanUserUseCase) {
        self.postId = postId
        self.reportRequest = CallVanReportRequest(reportedUserId: reportedUserId, descriptions: nil)
        self.uploadFileUseCase = uploadFileUseCase
        self.reportCallVanUserUseCase = reportCallVanUserUseCase
    }
    
    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case let .updateReasonCode(reasonCode, isSelected):
                updateReasonCode(reasonCode, isSelected)
            case let .updateCustomReason(customReason):
                updateCustomReason(customReason)
            case let .updateDescription(description):
                updateDescription(description)
            case let .uploadImage(imageData):
                uploadImage(imageData)
            case let .report(imageUrls):
                report(imageUrls)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanReportViewModel {
    
    private func updateReasonCode(_ reasonCode: CallVanReportRequestReasonCode, _ isSelected: Bool) {
        if isSelected {
            let reason = CallVanReportRequestReason(reasonCode: reasonCode, customReason: nil)
            reportRequest.reasons.insert(reason)
        } else {
            reportRequest.reasons = reportRequest.reasons.filter { $0.reasonCode != reasonCode }
        }
        validate()
    }
    
    private func updateCustomReason(_ customReason: String?) {
        if let reason = reportRequest.reasons.first(where: { $0.reasonCode == .other }) {
            reportRequest.reasons.remove(reason)
            reportRequest.reasons.insert(.init(reasonCode: .other, customReason: customReason))
        }
        validate()
    }
    
    private func updateDescription(_ description: String?) {
        reportRequest.descriptions = description
    }
    
    private func validate() {
        var validation: Bool = true
        if reportRequest.reasons.isEmpty {
            validation = false
        }
        if let other = reportRequest.reasons.first(where: { $0.reasonCode == .other}) {
            if let customReason = other.customReason,
               customReason.isEmpty {
                validation = false
            } else if other.customReason == nil {
                validation = false
            }
        }
        outputSubject.send(.validateNextButton(validation))
    }
    
    private func uploadImage(_ imageData: Data) {
        uploadFileUseCase.execute(files: [imageData], domain: .callVanReport).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] fileUploadResponse in
                if let imageUrl = fileUploadResponse.fileUrls.first {
                    self?.outputSubject.send(.apeendImageUrl(imageUrl))
                }
            }
        ).store(in: &subscriptions)
    }
    
    private func report(_ imageUrls: [String]) {
        reportRequest.imageUrls = imageUrls
        reportCallVanUserUseCase.execute(postId: postId, request: reportRequest).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] _ in
                self?.outputSubject.send(.reportCompleted)
            }
        ).store(in: &subscriptions)
    }
}
