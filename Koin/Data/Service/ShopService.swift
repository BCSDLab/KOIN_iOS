//
//  ShopService.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Foundation
import Alamofire
import Combine

protocol ShopService {
    func fetchShopMenusCategory(shopId: Int) -> AnyPublisher<ShopMenusCategoryDto, ErrorResponse>
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDto, ErrorResponse>
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDto, ErrorResponse>
    func fetchEventList() -> AnyPublisher<EventsDto, ErrorResponse>
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDto, ErrorResponse>
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDto, ErrorResponse>
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDto, ErrorResponse>
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDto, ErrorResponse>
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDto, ErrorResponse>
        
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDto, ErrorResponse>
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDto, ErrorResponse>
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDto, ErrorResponse>
    func postReview(requestModel: WriteReviewRequest, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func modifyReview(requestModel: WriteReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteReview(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func reportReview(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDto, ErrorResponse>
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDto, ErrorResponse>
    
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func uploadFiles(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse>
    
    func fetchSearchShop(requestModel: FetchShopSearchRequest) -> AnyPublisher<ShopSearchDto, ErrorResponse>
    
}

final class DefaultShopService: ShopService {
    
    private let networkService = NetworkService()
    
    func fetchShopMenusCategory(shopId: Int) -> AnyPublisher<ShopMenusCategoryDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopMenusCategoryList(shopId: shopId))
    }
    
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopSummary(id))
    }
    
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopBenefits)
    }
    
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchBeneficialShops(id))
    }
    
    func uploadFiles(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse> {
        return networkService.uploadFiles(api: ShopAPI.uploadFiles(files))
    }
    
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchReviewList(requestModel))
    }
    
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchReview(reviewId, shopId))
    }
    
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchMyReviewList(requestModel, shopId))
    }
    
    func postReview(requestModel: WriteReviewRequest, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.postReview(requestModel, shopId))
    }
    
    func modifyReview(requestModel: WriteReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.modifyReview(requestModel, reviewId, shopId))
    }
    
    func deleteReview(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.deleteReview(reviewId, shopId))
    }
    
    func reportReview(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.reportReview(requestModel, reviewId, shopId))
    }
    
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopList(requestModel))
    }
    
    func fetchEventList() -> AnyPublisher<EventsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchEventList)
    }
    
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopCategoryList)
    }
    
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopData(requestModel))
    }
    
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopMenuList(requestModel))
    }
    
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopEventList(requestModel))
    }
    
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.searchShop(text))
    }
    
    func fetchSearchShop(requestModel: FetchShopSearchRequest) -> AnyPublisher<ShopSearchDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchSearchShop(requestModel))
    }
    
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.postCallNotification(shopId))
    }
}
