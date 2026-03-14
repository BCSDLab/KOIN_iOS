//
//  DefaultShopRepository.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine

final class DefaultShopRepository: ShopRepository {

    private let service: ShopService
    
    init(service: ShopService) {
        self.service = service
    }
    
    func fetchShopMenusCategoryList(shopId: Int) -> AnyPublisher<ShopMenusCategoryDto, ErrorResponse> {
        service.fetchShopMenusCategory(shopId: shopId)
    }
    
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDto, ErrorResponse> {
        service.fetchShopSummary(id: id)
    }
    
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDto, ErrorResponse> {
        service.fetchBeneficialShops(id: id)
    }
    
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDto, ErrorResponse> {
        service.fetchShopBenefits()
    }
    
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDto, ErrorResponse> {
        return service.fetchShopList(requestModel: requestModel)
    }
    
    func fetchEventList() -> AnyPublisher<EventsDto, ErrorResponse> {
        return service.fetchEventList()
    }
    
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDto, ErrorResponse> {
        return service.fetchShopCategoryList()
    }
    
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDto, ErrorResponse> {
        return service.fetchShopData(requestModel: requestModel)
    }
    
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDto, ErrorResponse> {
        return service.fetchShopMenuList(requestModel: requestModel)
    }
    
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDto, ErrorResponse> {
        return service.fetchShopEventList(requestModel: requestModel)
    }
    
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDto, ErrorResponse> {
        return service.fetchReviewList(requestModel: requestModel)
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
    
    func searchRelatedQuery(text: String) -> AnyPublisher<RelatedKeywordsDto, ErrorResponse> { // TODO: 삭제 예정
        return service.searchRelatedShops(text: text)
    }
    
    func fetchSearchShop(requestModel: FetchShopSearchRequest) -> AnyPublisher<ShopSearch, ErrorResponse> {
        return service.fetchSearchShop(requestModel: requestModel)
            .map { dto in
                ShopSearch(from: dto)
            }
            .eraseToAnyPublisher()
    }
}
