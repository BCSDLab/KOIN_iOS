//
//  DefaultShopRepository.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine
import Foundation

final class DefaultShopRepository: ShopRepository {

    private let service: ShopService
    
    init(service: ShopService) {
        self.service = service
    }
    
    func fetchShopMenusCategoryList(shopId: Int) -> AnyPublisher<ShopMenusCategoryDto, Error> {
        service.fetchShopMenusCategory(shopId: shopId)
    }
    
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDto, Error> {
        service.fetchShopSummary(id: id)
    }
    
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDto, Error> {
        service.fetchBeneficialShops(id: id)
    }
    
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDto, Error> {
        service.fetchShopBenefits()
    }
    
    func uploadFiles(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse> {
        service.uploadFiles(files: files)
    }
    
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDto, Error> {
        return service.fetchShopList(requestModel: requestModel)
    }
    
    func fetchEventList() -> AnyPublisher<EventsDto, Error> {
        return service.fetchEventList()
    }
    
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDto, Error> {
        return service.fetchShopCategoryList()
    }
    
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDto, Error> {
        return service.fetchShopData(requestModel: requestModel)
    }
    
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDto, Error> {
        return service.fetchShopMenuList(requestModel: requestModel)
    }
    
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDto, Error> {
        return service.fetchShopEventList(requestModel: requestModel)
    }
    
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDto, ErrorResponse> {
        return service.fetchReviewList(requestModel: requestModel, retry: false)
    }
    
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDto, ErrorResponse> {
        return service.fetchReview(reviewId: reviewId, shopId: shopId)
    }
    
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDto, ErrorResponse> {
        return service.fetchMyReviewList(requestModel: requestModel, shopId: shopId)
    }
    
    func postReview(requestModel: WriteReviewRequest, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.postReview(requestModel: requestModel, shopId: shopId)
    }
    
    func modifyReview(requestModel: WriteReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.modifyReview(requestModel: requestModel, reviewId: reviewId, shopId: shopId)
    }
    
    func deleteReview(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.deleteReview(reviewId: reviewId, shopId: shopId)
    }
    
    func reportReview(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.reportReview(requestModel: requestModel, reviewId: reviewId, shopId: shopId)
    }
    
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.postCallNotification(shopId: shopId)
    }
    
    func searchRelatedQuery(text: String) -> AnyPublisher<RelatedKeywordsDto, Error> {
        return service.searchRelatedShops(text: text)
    }
}
