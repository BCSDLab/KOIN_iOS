//
//  FetchNoticeArticlesUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Combine

protocol FetchNoticeArticlesUseCase {
    func fetchArticles(boardId: Int, keyWord: String?, page: Int) -> AnyPublisher<NoticeArticlesInfo, Error>
}

final class DefaultFetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase {
    private let noticeListRepository: NoticeListRepository
    private let maxArticleListNumber: Int = 10
    private let maxPagesNumber: Int = 5
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func fetchArticles(boardId: Int, keyWord: String?, page: Int) -> AnyPublisher<NoticeArticlesInfo, Error> {
        if let keyWord = keyWord {
            let requestModel = SearchNoticeArticleRequest(query: keyWord, boardId: boardId, page: page, limit: maxArticleListNumber)
            return noticeListRepository.searchNoticeArticle(requestModel: requestModel).map { [weak self] articles in
                let pages = self?.makePages(currentPage: articles.currentPage, totalPage: articles.totalPage) ?? NoticeListPages(isPreviousPage: nil, pages: [], selectedIndex: 0, isNextPage: nil)
                return NoticeArticlesInfo(articles: articles.articles ?? [], pages: pages)
            }.eraseToAnyPublisher()
        }
        else {
           let requestModel = FetchNoticeArticlesRequest(boardId: boardId, page: page, limit: maxArticleListNumber)
            return noticeListRepository.fetchNoticeArticles(requestModel: requestModel).map { [weak self] articles in
                let pages = self?.makePages(currentPage: articles.currentPage, totalPage: articles.totalPage) ?? NoticeListPages(isPreviousPage: nil, pages: [], selectedIndex: 0, isNextPage: nil)
                return NoticeArticlesInfo(articles: articles.articles ?? [], pages: pages)
            }.eraseToAnyPublisher()
        }
    }
    
    private func makePages(currentPage: Int, totalPage: Int) -> NoticeListPages {
        if totalPage == 0 {
            return NoticeListPages(isPreviousPage: nil, pages: [], selectedIndex: 0, isNextPage: nil)
        }
        var isPreviousPage: PageReloadDirection? = nil
        var isNextPage: PageReloadDirection? = nil
        var pages: [Int] = []
        
        let startPage = ((currentPage - 1) / maxPagesNumber * maxPagesNumber) + 1
        var endPage = totalPage
        
        if startPage > 5 {
            isPreviousPage = .previousPage
        }
        if totalPage > maxPagesNumber && (totalPage - startPage) > maxPagesNumber {
            endPage = (currentPage - 1) / maxPagesNumber * maxPagesNumber + maxPagesNumber
        }
        if endPage < totalPage {
            isNextPage = .nextPage
        }
        pages = Array(startPage...endPage)
        return NoticeListPages(isPreviousPage: isPreviousPage, pages: pages, selectedIndex: currentPage, isNextPage: isNextPage)
    }
}
