//
//  ShopRepository.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Combine
import Foundation

protocol ShopRepository {
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDTO, Error>
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDTO, Error>
    func fetchEventList() -> AnyPublisher<EventsDTO, Error>
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDTO, Error>
    
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDTO, Error>
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDTO, Error>
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDTO, Error>
    
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDTO, ErrorResponse>
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDTO, ErrorResponse>
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDTO, ErrorResponse>
    func postReview(requestModel: WriteReviewRequest, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func modifyReview(requestModel: WriteReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteReview(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func reportReview(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDTO, Error>
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDTO, Error>
    func searchRelatedQuery(text: String) -> AnyPublisher<RelatedKeywordsDTO, Error>
    
    func uploadFiles(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse>
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse>
}

