//
//  FetchNoticeArticlesUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Combine
import Foundation

protocol FetchNoticeArticlesUseCase {
    func execute(boardId: Int?, keyWord: String?, page: Int) -> AnyPublisher<NoticeArticlesInfo, Error>
}

final class DefaultFetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase {
    private let noticeListRepository: NoticeListRepository
    private let maxArticleListNumber: Int = 10
    private let maxPagesNumber: Int = 5
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(boardId: Int?, keyWord: String?, page: Int) -> AnyPublisher<NoticeArticlesInfo, Error> {
        let request: AnyPublisher<NoticeListDTO, Error>
        
        if let keyWord = keyWord { // 키워드로 검색해서 찾을 경우
            let searchRequest = SearchNoticeArticleRequest(query: keyWord, boardId: boardId, page: page, limit: maxArticleListNumber)
            request = noticeListRepository.searchNoticeArticle(requestModel: searchRequest)
        } else if let boardId = boardId { //키워드 없는 공지사항 목록을 원할 경우
            let fetchRequest = FetchNoticeArticlesRequest(boardId: boardId, page: page, limit: maxArticleListNumber)
            request = noticeListRepository.fetchNoticeArticles(requestModel: fetchRequest)
        } else { // boardId는 꼭 필요하기 때문에 없다면 빈 배열을 반환
            request = Just(NoticeListDTO(articles: [], totalCount: 0, currentCount: 0, totalPage: 0, currentPage: 0))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return request
            .map { [weak self] articles in
                let newArticles: NoticeListDTO = articles.toDomain()
                let pages = self?.makePages(currentPage: articles.currentPage, totalPage: articles.totalPage) ?? NoticeListPages(isPreviousPage: nil, pages: [], selectedIndex: 0, isNextPage: nil)
                return NoticeArticlesInfo(articles: newArticles.articles ?? [], pages: pages)
            }
            .eraseToAnyPublisher()
    }
    
    private func makePages(currentPage: Int, totalPage: Int) -> NoticeListPages {
        guard totalPage > 0 else {
            return NoticeListPages(isPreviousPage: nil, pages: [], selectedIndex: 0, isNextPage: nil)
        }
        
        let isPreviousPage: PageReloadDirection? = currentPage > 5 ? .previousPage : nil
        var isNextPage: PageReloadDirection? = nil
        var pages: [Int]
        
        let startPage = max(1, (currentPage - 1) / maxPagesNumber * maxPagesNumber + 1)
        let endPage = min(startPage + maxPagesNumber - 1, totalPage)
        
        if endPage < totalPage {
            isNextPage = .nextPage
        }
        
        pages = Array(startPage...endPage)
        return NoticeListPages(isPreviousPage: isPreviousPage, pages: pages, selectedIndex: currentPage, isNextPage: isNextPage)
    }
}
