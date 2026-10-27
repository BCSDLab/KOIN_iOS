//
//  NoticeListHostingController.swift
//  koin
//
//  Created by 홍기정 on 10/22/26.
//

import SwiftUI

final class NoticeListHostingController: UIHostingController<NoticeListView>, HostingControllerProtocol {

    // MARK: - Initializer
    override init(rootView: NoticeListView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
    }
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appColor(.neutral0)
    }

    // MARK: - Execute
    func execute(action: RootView.Action) {
        switch action {
        case .showToastMessage(let message):
            showToastMessage(message: message)
        case let .navigateToNoticeData(noticeId, boardId):
            navigateToNoticeData(noticeId: noticeId, boardId: boardId)
        case .navigateToSearch:
            navigateToSearch()
        case .navigateToManageKeyword:
            navigateToManageKeyword()
        }
    }
}

extension NoticeListHostingController {
    private func navigateToNoticeData(noticeId: Int, boardId: Int) {
        let noticeListService = DefaultNoticeService()
        let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
        let fetchNoticeDataUseCase = DefaultFetchNoticeDataUseCase(noticeListRepository: noticeListRepository)
        let downloadNoticeAttachmentUseCase = DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: noticeListRepository)
        let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: noticeListRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: fetchNoticeDataUseCase, fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: downloadNoticeAttachmentUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, noticeId: noticeId, boardId: boardId)
        let noticeDataVc = NoticeDataViewController(viewModel: viewModel)
        navigationController?.pushViewController(noticeDataVc, animated: true)
    }

    private func navigateToSearch() {
        let repository = DefaultNoticeListRepository(service: DefaultNoticeService())
        let fetchHotKeywordUseCase = DefaultFetchHotSearchingKeywordUseCase(noticeListRepository: repository)
        let searchNoticeArticlesUseCase = DefaultSearchNoticeArticlesUseCase(noticeRepository: repository)
        let manageRecentSearchedWordUseCase = DefaultManageRecentSearchedWordUseCase(noticeListRepository: repository)
        let fetchRecentSearchedWordUseCase = DefaultFetchRecentSearchedWordUseCase(noticeListRepository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NoticeSearchViewModel(fetchHotKeywordUseCase: fetchHotKeywordUseCase, manageRecentSearchedWordUseCase: manageRecentSearchedWordUseCase, searchNoticeArticlesUseCase: searchNoticeArticlesUseCase, fetchRecentSearchedWordUseCase: fetchRecentSearchedWordUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let vc = NoticeSearchViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToManageKeyword() {
        let noticeListService = DefaultNoticeService()
        let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
        let addNotificationKeywordUseCase = DefaultAddNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
        let deleteNotificationKeywordUseCase = DefaultDeleteNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
        let fetchNotificationKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))
        let fetchRecommendedKeywordUseCase = DefaultFetchRecommendedKeywordUseCase(noticeListRepository: noticeListRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = ManageNoticeKeywordViewModel(addNotificationKeywordUseCase: addNotificationKeywordUseCase, deleteNotificationKeywordUseCase: deleteNotificationKeywordUseCase, fetchNotificationKeywordUseCase: fetchNotificationKeywordUseCase, fetchRecommendedKeywordUseCase: fetchRecommendedKeywordUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUseCase: fetchNotiListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let viewController = ManageNoticeKeywordViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
