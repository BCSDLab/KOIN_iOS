//
//  NoticeListService.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Alamofire
import Combine

protocol NoticeListService {
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error>
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDTO, Error>
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDTO, Error>
    func fetchHotNoticeArticles() -> AnyPublisher<[NoticeArticleDTO], Error>
    func createNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse>
    func deleteNotificationKeyWord(requestModel: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultNoticeService: NoticeListService {
    let networkService = NetworkService()
    
    func fetchNoticeArticles(requestModel: FetchNoticeArticlesRequest) -> AnyPublisher<NoticeListDTO, Error> {
        return request(.fetchNoticeArticles(requestModel))
    }
    
    func searchNoticeArticle(requestModel: SearchNoticeArticleRequest) -> AnyPublisher<NoticeListDTO, Error> {
        return request(.searchNoticeArticle(requestModel))
    }
    
    func fetchNoticeData(requestModel: FetchNoticeDataRequest) -> AnyPublisher<NoticeArticleDTO, Error> {
        return request(.fetchNoticedata(requestModel))
    }
    
    func fetchHotNoticeArticles() -> AnyPublisher<[NoticeArticleDTO], Error> {
        return request(.fetchHotNoticeArticles)
    }
    
    func createNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse> {
        return networkService.requestWithResponse(api: NoticeListAPI.createNotificationKeyWord(requestModel))
            .catch { [weak self] error -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: NoticeListAPI.createNotificationKeyWord(requestModel)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteNotificationKeyWord(requestModel: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: NoticeListAPI.deleteNotificationKeyWord(requestModel))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: NoticeListAPI.deleteNotificationKeyWord(requestModel)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    private func request<T: Decodable>(_ api: NoticeListAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
