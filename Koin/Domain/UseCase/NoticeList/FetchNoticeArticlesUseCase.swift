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
        var isPreviousPage: PageReloadDirection? = nil
        var isNextPage: PageReloadDirection? = nil
        if currentPage > (maxPagesNumber / 2) {
            isPreviousPage = .previousPage
        }
        if currentPage + (maxPagesNumber / 2) < totalPage {
            isNextPage = .nextPage
        }
        var pages: [Int] = []
        
        let startPage = max(1, currentPage - maxPagesNumber / 2)
        let endPage = min(totalPage, currentPage + maxPagesNumber / 2)
        
        pages = Array(startPage...endPage)
        return NoticeListPages(isPreviousPage: isPreviousPage, pages: pages, selectedIndex: currentPage, isNextPage: isNextPage)
    }
}
