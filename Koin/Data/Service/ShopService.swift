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
    func fetchShopMenusCategory(shopId: Int) -> AnyPublisher<ShopMenusCategoryDto, Error>
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDto, Error>
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDto, Error>
    func fetchEventList() -> AnyPublisher<EventsDto, Error>
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDto, Error>
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDto, Error>
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDto, Error>
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDto, Error>
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDto, Error>
        
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDto, ErrorResponse>
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDto, ErrorResponse>
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDto, ErrorResponse>
    func postReview(requestModel: WriteReviewRequest, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func modifyReview(requestModel: WriteReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteReview(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func reportReview(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDto, Error>
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDto, Error>
    
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func uploadFiles(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse>
    
    func fetchSearchShop(requestModel: FetchShopSearchRequest) -> AnyPublisher<ShopSearchDto, Error>
    
}

final class DefaultShopService: ShopService {
    
    private let networkService = NetworkService()
    
    func fetchShopMenusCategory(shopId: Int) -> AnyPublisher<ShopMenusCategoryDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopMenusCategoryList(shopId: shopId))
    }
    
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopSummary(id))
    }
    
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopBenefits)
    }
    
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDto, Error> {
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
    
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopList(requestModel))
    }
    
    func fetchEventList() -> AnyPublisher<EventsDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchEventList)
    }
    
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopCategoryList)
    }
    
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopData(requestModel))
    }
    
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopMenuList(requestModel))
    }
    
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchShopEventList(requestModel))
    }
    
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.searchShop(text))
    }
    
    func fetchSearchShop(requestModel: FetchShopSearchRequest) -> AnyPublisher<ShopSearchDto, Error> {
        return networkService.requestWithResponse(api: ShopAPI.fetchSearchShop(requestModel))
    }
    
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.postCallNotification(shopId))
    }
}
