//
//  LostItemService.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation
import Combine
import Alamofire

protocol LostItemService {
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemListDto, ErrorResponse>
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemDataDto, ErrorResponse>
    func changeLostItemState(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func updateLostItem(id: Int, requestModel: UpdateLostItemRequest) -> AnyPublisher<LostItemDataDto, ErrorResponse>
    func fetchLostItemStats() -> AnyPublisher<LostItemStatsDto, ErrorResponse>
    func postLostItem(request: [PostLostItemRequest]) -> AnyPublisher<LostItemDataDto, ErrorResponse>
    func reportLostItemArticle(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse>
    
    func subscribeKeyword(requestModel: SubscribeKeywordRequest) -> AnyPublisher<LostItemKeywordDto, ErrorResponse>
    func fetchKeywordSuggestion() -> AnyPublisher<LostItemKeywordSuggestionDto, ErrorResponse>
    func fetchMyKeyword() -> AnyPublisher<LostItemKeywordsDto, ErrorResponse>
    func unsubscribeKeyword(id: Int) -> AnyPublisher<Void, ErrorResponse>

    func fetchChatRoom() -> AnyPublisher<[LostItemChatRoomDto], ErrorResponse>
    func fetchChatDetail(articleId: Int, chatRoomId: Int) -> AnyPublisher<[LostItemChatDetailDto], ErrorResponse>
    func blockUser(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse>
    func createChatRoom(articleId: Int) -> AnyPublisher<LostItemCreateChatRoomResponse, ErrorResponse>
    func postChatDetail(articleId: Int, chatRoomId: Int, request: LostItemPostChatDetailRequest) -> AnyPublisher<LostItemChatDetailDto, ErrorResponse>
}

final class DefaultLostItemService: LostItemService {
    
    private let networkService = NetworkService.shared
    
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemListDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchLostItemList(requestModel))
    }
    
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchLostItemData(id))
    }
    
    func changeLostItemState(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: LostItemAPI.changeListItemState(id))
    }
    
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: LostItemAPI.deleteLostItem(id))
    }
    
    func updateLostItem(id: Int, requestModel: UpdateLostItemRequest) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.updateLostItem((id, requestModel)))
    }
    
    func fetchLostItemStats() -> AnyPublisher<LostItemStatsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchLostItemStats)
    }
    
    func reportLostItemArticle(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: LostItemAPI.reportLostItem(id, request))
    }
    
    func postLostItem(request: [PostLostItemRequest]) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.postLostItem(request))
    }
    
    func subscribeKeyword(requestModel: SubscribeKeywordRequest) -> AnyPublisher<LostItemKeywordDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.subscribeKeyword(requestModel))
    }
    
    func fetchKeywordSuggestion() -> AnyPublisher<LostItemKeywordSuggestionDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchKeywordSuggestion)
    }
    
    func fetchMyKeyword() -> AnyPublisher<LostItemKeywordsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchMyKeyword)
    }
    
    func unsubscribeKeyword(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: LostItemAPI.unsubscribeKeyword(id))
    }

    func createChatRoom(articleId: Int) -> AnyPublisher<LostItemCreateChatRoomResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.createChatRoom(articleId))
    }

    func blockUser(articleId: Int, chatRoomId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: LostItemAPI.blockUser(articleId, chatRoomId))
    }

    func fetchChatDetail(articleId: Int, chatRoomId: Int) -> AnyPublisher<[LostItemChatDetailDto], ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchChatDetail(articleId, chatRoomId))
    }

    func fetchChatRoom() -> AnyPublisher<[LostItemChatRoomDto], ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchChatRoom)
    }

    func postChatDetail(articleId: Int, chatRoomId: Int, request: LostItemPostChatDetailRequest) -> AnyPublisher<LostItemChatDetailDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.postChatDetail(articleId, chatRoomId, request))
    }
}
