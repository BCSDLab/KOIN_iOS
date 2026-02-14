//
//  ShopRepository.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine
import Foundation

protocol ShopRepository {
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDto, ErrorResponse>
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDto, ErrorResponse>
    func fetchEventList() -> AnyPublisher<EventsDto, ErrorResponse>
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDto, ErrorResponse>
    func fetchShopMenusCategoryList(shopId: Int) -> AnyPublisher<ShopMenusCategoryDto, ErrorResponse>
    
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDto, ErrorResponse>
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDto, ErrorResponse>
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDto, ErrorResponse>
    
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDto, ErrorResponse>
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDto, ErrorResponse>
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDto, ErrorResponse>
    func postReview(requestModel: WriteReviewRequest, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func modifyReview(requestModel: WriteReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteReview(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func reportReview(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDto, ErrorResponse>
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDto, ErrorResponse>
    func searchRelatedQuery(text: String) -> AnyPublisher<RelatedKeywordsDto, ErrorResponse>
    
    func uploadFiles(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse>
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func fetchSearchShop(requestModel: FetchShopSearchRequest) -> AnyPublisher<ShopSearch, ErrorResponse>
}

