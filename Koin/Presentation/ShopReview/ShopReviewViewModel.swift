//
//  ShopReviewViewModel.swift
//  koin
//
//  Created by 김나훈 on 7/8/24.
//

import Combine
import Foundation

final class ShopReviewViewModel: ViewModelProtocol {
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let postReviewUseCase: PostReviewUseCase
    private let modifyReviewUseCase: ModifyReviewUseCase
    private let fetchShopReviewUseCase: FetchShopReviewUseCase
    private let uploadFileUseCase: UploadFileUseCase
    private let fetchShopDataUseCase: FetchShopDataUseCase
    private let reviewId: Int?
    private let shopId: Int
    
    enum Input {
        case writeReview(WriteReviewRequest)
        case uploadFile([Data])
        case checkModify
        case updateShopName
    }
    
    enum Output {
        case fillComponent(OneReviewDTO)
        case addImage(String)
        case showToast(String, Bool)
        case updateShopName(String)
    }
    
    init(postReviewUseCase: PostReviewUseCase, modifyReviewUseCase: ModifyReviewUseCase, fetchShopReviewUseCase: FetchShopReviewUseCase, uploadFileUseCase: UploadFileUseCase, fetchShopDataUseCase: FetchShopDataUseCase, reviewId: Int? = nil, shopId: Int) {
        self.postReviewUseCase = postReviewUseCase
        self.modifyReviewUseCase = modifyReviewUseCase
        self.fetchShopReviewUseCase = fetchShopReviewUseCase
        self.uploadFileUseCase = uploadFileUseCase
        self.fetchShopDataUseCase = fetchShopDataUseCase
        self.reviewId = reviewId
        self.shopId = shopId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self = self else { return }
            switch input {
            case let .writeReview(requestModel):
                if let reviewId = self.reviewId { self.modifyReview(requestModel: requestModel, reviewId: reviewId) }
                else { self.postReview(requestModel: requestModel) }
            case let .uploadFile(data):
                self.uploadFile(files: data)
            case .checkModify:
                if let _ = reviewId { fetchShopReview() }
            case .updateShopName:
                self.updateShopName()
            }
            
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func updateShopName() {
        fetchShopDataUseCase.execute(shopId: shopId) .sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateShopName(response.name))
        }.store(in: &subscriptions)
    }
    
    private func uploadFile(files: [Data]) {
        uploadFileUseCase.execute(files: files).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            if let imageUrl = response.fileUrls.first {
                self?.outputSubject.send(.addImage(imageUrl))
            }
        }.store(in: &subscriptions)

    }
    
    private func fetchShopReview() {
        guard let reviewId = reviewId else { return }
        fetchShopReviewUseCase.execute(reviewId: reviewId, shopId: shopId).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.fillComponent(response))
        }.store(in: &subscriptions)
    }
    
    private func postReview(requestModel: WriteReviewRequest) {
        postReviewUseCase.execute(requestModel: requestModel, shopId: shopId).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("리뷰가 작성되었습니다.", true))
        }.store(in: &subscriptions)
    }
    
    private func modifyReview(requestModel: WriteReviewRequest, reviewId: Int) {
        modifyReviewUseCase.execute(requestModel: requestModel, reviewId: reviewId, shopId: shopId).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("리뷰가 수정되었습니다.", true))
        }.store(in: &subscriptions)
        
    }
}
