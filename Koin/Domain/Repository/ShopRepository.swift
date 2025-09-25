//
//  ShopRepository.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine
import Foundation

protocol ShopRepository {
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDto, Error>
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDto, Error>
    func fetchEventList() -> AnyPublisher<EventsDto, Error>
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDto, Error>
    func fetchShopMenusCategoryList(shopId: Int) -> AnyPublisher<ShopMenusCategoryDto, Error>
    
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDto, Error>
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDto, Error>
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDto, Error>
    
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDto, ErrorResponse>
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDto, ErrorResponse>
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDto, ErrorResponse>
    func postReview(requestModel: WriteReviewRequest, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func modifyReview(requestModel: WriteReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteReview(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func reportReview(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDto, Error>
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDto, Error>
    func searchRelatedQuery(text: String) -> AnyPublisher<RelatedKeywordsDto, Error>
    
    func uploadFiles(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse>
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse>
}

