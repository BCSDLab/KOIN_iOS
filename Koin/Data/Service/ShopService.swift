//
//  ShopService.swift
//  koin
//
//  Created by 김나훈 on 5/22/24.
//

import Alamofire
import Combine

protocol ShopService {
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDTO, Error>
    func fetchEventList() -> AnyPublisher<EventsDTO, Error>
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDTO, Error>
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDTO, Error>
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDTO, Error>
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDTO, Error>
    
    func fetchReviewList(requestModel: FetchShopReviewRequest, retry: Bool) -> AnyPublisher<ReviewsDTO, ErrorResponse>
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDTO, ErrorResponse>
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDTO, ErrorResponse>
    func postReview(requestModel: WriteReviewRequest, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func modifyReview(requestModel: WriteReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteReview(reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func reportReview(requestModel: ReportReviewRequest, reviewId: Int, shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDTO, Error>
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDTO, Error>
    
    func postCallNotification(shopId: Int) -> AnyPublisher<Void, ErrorResponse>
    func uploadFiles(files: [Data]) -> AnyPublisher<FileUploadResponse, ErrorResponse>
    
}

final class DefaultShopService: ShopService {
    
    private let networkService = NetworkService()
    
    func fetchShopBenefits() -> AnyPublisher<ShopBenefitsDTO, Error> {
        request(.fetchShopBenefits)
    }
    
    func fetchBeneficialShops(id: Int) -> AnyPublisher<ShopsDTO, Error> {
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
    
    func fetchReviewList(requestModel: FetchShopReviewRequest, retry: Bool) -> AnyPublisher<ReviewsDTO, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchReviewList(requestModel))
            .catch { [weak self] error -> AnyPublisher<ReviewsDTO, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" && !retry {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: ShopAPI.fetchReviewList(requestModel)) }
                        .catch { refreshError -> AnyPublisher<ReviewsDTO, ErrorResponse> in
                            return self.fetchReviewList(requestModel: requestModel, retry: true)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchReview(reviewId: Int, shopId: Int) -> AnyPublisher<OneReviewDTO, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchReview(reviewId, shopId))
            .catch { [weak self] error -> AnyPublisher<OneReviewDTO, ErrorResponse> in
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
    
    func fetchMyReviewList(requestModel: FetchMyReviewRequest, shopId: Int) -> AnyPublisher<MyReviewDTO, ErrorResponse> {
        return networkService.requestWithResponse(api: ShopAPI.fetchMyReviewList(requestModel, shopId))
            .catch { [weak self] error -> AnyPublisher<MyReviewDTO, ErrorResponse> in
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
    
    func fetchShopList(requestModel: FetchShopListRequest) -> AnyPublisher<ShopsDTO, Error> {
        return request(.fetchShopList(requestModel))
    }
    
    func fetchEventList() -> AnyPublisher<EventsDTO, Error> {
        return request(.fetchEventList)
    }
    
    func fetchShopCategoryList() -> AnyPublisher<ShopCategoryDTO, Error> {
        return request(.fetchShopCategoryList)
    }
    
    func fetchShopData(requestModel: FetchShopDataRequest) -> AnyPublisher<ShopDataDTO, Error> {
        return request(.fetchShopData(requestModel))
    }
    
    func fetchShopMenuList(requestModel: FetchShopDataRequest) -> AnyPublisher<MenuDTO, Error> {
        return request(.fetchShopMenuList(requestModel))
    }
    
    func fetchShopEventList(requestModel: FetchShopDataRequest) -> AnyPublisher<EventsDTO, Error> {
        return request(.fetchShopEventList(requestModel))
    }
    
    func fetchReviewList(requestModel: FetchShopReviewRequest) -> AnyPublisher<ReviewsDTO, Error> {
        return request(.fetchReviewList(requestModel))
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
