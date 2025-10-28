//
//  ShopService.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

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
        
    func fetchReviewList(requestModel: FetchShopReviewRequest, retry: Bool) -> AnyPublisher<ReviewsDto, ErrorResponse>
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
    
}

final class DefaultShopService: ShopService {
    
    private let networkService = NetworkService()
    
    func fetchShopMenusCategory(shopId: Int) -> AnyPublisher<ShopMenusCategoryDto, Error> {
        request(.fetchShopMenusCategoryList(shopId: shopId))
    }
    
    func fetchShopSummary(id: Int) -> AnyPublisher<ShopSummaryDto, Error> {
        request(.fetchShopSummary(id))
        
    }
    
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDto, Error> {
        request(.fetchShopBenefits)
    }
    
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDto, Error> {
        request(.fetchBeneficialShops(id))
    }
    
    func uploadFiles(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse> {
        return networkService.uploadFiles(api: ShopAPI.uploadFiles(files))
            .catch { [weak self] error -> AnyPublisher<FileUploadResponse, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.uploadFiles(api: ShopAPI.uploadFiles(files)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchReviewList(requestModel: FetchShopReviewRequest, retry: Bool) -> AnyPublisher<ReviewsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchReviewList(requestModel))
            .catch { [weak self] error -> AnyPublisher<ReviewsDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" && !retry {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: ShopAPI.fetchReviewList(requestModel)) }
                        .catch { refreshError -> AnyPublisher<ReviewsDto, ErrorResponse> in
                            return self.fetchReviewList(requestModel: requestModel, retry: true)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchReview(reviewId, shopId))
            .catch { [weak self] error -> AnyPublisher<OneReviewDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: ShopAPI.fetchReview(reviewId, shopId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDto, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchMyReviewList(requestModel, shopId))
            .catch { [weak self] error -> AnyPublisher<MyReviewDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: ShopAPI.fetchMyReviewList(requestModel, shopId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func postReview(requestModel: WriteReviewRequest, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.postReview(requestModel, shopId))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: ShopAPI.postReview(requestModel, shopId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func modifyReview(requestModel: WriteReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.modifyReview(requestModel, reviewId, shopId))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: ShopAPI.modifyReview(requestModel, reviewId, shopId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteReview(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.deleteReview(reviewId, shopId))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: ShopAPI.deleteReview(reviewId, shopId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func reportReview(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.reportReview(requestModel, reviewId, shopId))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: ShopAPI.reportReview(requestModel, reviewId, shopId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDto, Error> {
        return request(.fetchShopList(requestModel))
    }
    
    func fetchEventList() -> AnyPublisher<EventsDto, Error> {
        return request(.fetchEventList)
    }
    
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDto, Error> {
        return request(.fetchShopCategoryList)
    }
    
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDto, Error> {
        return request(.fetchShopData(requestModel))
    }
    
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDto, Error> {
        return request(.fetchShopMenuList(requestModel))
    }
    
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDto, Error> {
        return request(.fetchShopEventList(requestModel))
    }
    
    func searchRelatedShops(text: String) -> AnyPublisher<RelatedKeywordsDto, Error> {
        return request(.searchShop(text))
    }
    
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: ShopAPI.postCallNotification(shopId))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: ShopAPI.postCallNotification(shopId)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func request<T: Decodable>(_ api: ShopAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
