//
//  NotificationViewController.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import UIKit
import Combine
import SnapKit

final class NotificationViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: NotificationViewModel
    private let inputSubject = PassthroughSubject<NotificationViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - UI Components
    private let notificationListView = NotificationListView()

    // MARK: - Initialization
    init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationBar()
        bind()
        notificationListView.startLoading()
        inputSubject.send(.viewDidLoad)
        title = "알림"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
}

// MARK: - Bind

private extension NotificationViewController {
    func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                
                switch event {
                case .updateNotifications(let notifications):
                    notificationListView.update(items: notifications.map { $0.toNotificationRowModel() })
                case .selectedNotification(let notification):
                    handleNavigation(notification)
                case .showToast(let message):
                    showToastMessage(message: message)
                }
            }
            .store(in: &subscriptions)
        
        notificationListView.deletePublisher
            .sink { [weak self] id in
                guard let self else { return }
                self.inputSubject.send(.deleteNotification(id: id))
                self.showToastMessage(message: "알림이 삭제되었습니다.")
                self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.notificationListDelete, .click, "알림 삭제"))
            }
            .store(in: &subscriptions)
        
        notificationListView.itemTappedPublisher
            .sink { [weak self] id in
                self?.inputSubject.send(.selectNotification(id: id))
            }
            .store(in: &subscriptions)

        notificationListView.refreshPublisher
            .sink { [weak self] in
                self?.inputSubject.send(.reload)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Navigation

extension NotificationViewController {
    private func handleNavigation(_ item: NotificationHistoryItem) {
        guard let uri: String = item.uri,
              let parsedQuery = parseQuery(uri: uri) else {
            return
        }
        switch item.appPath {
        case .shop:
            if let shopId = Int(parsedQuery["id"]) {
                navigateToShop(shopId: shopId)
            }
        case .dining:
            navigateToDining()
        case .chat:
            if let articleId = Int(parsedQuery["articleId"]),
               let chatRoomId = Int(parsedQuery["chatRoomId"]) {
                navigateToChat(articleId: articleId, chatRoomId: chatRoomId)
            }
        case .callvan:
            if let postId = Int(parsedQuery["id"]) {
                navigateToCallVanData(postId: postId)
            }
        case .callvanChat:
            if let postId = Int(parsedQuery["postId"]) {
                navigateToCallVanChat(postId: postId)
            }
        case .keyword:
            guard let noticeId = Int(parsedQuery["id"]),
                  let boardId = Int(parsedQuery["board-id"]) else {
                return
            }
            if boardId == 14 {
                navigateToLostItemData(lostItemId: noticeId)
            } else {
                navigateToKeyword(boardId: boardId, noticeId: noticeId)
            }
        }
    }
}


extension NotificationViewController {
    private func parseQuery(uri: String) -> [String: String]? {
        if let components = URLComponents(string: uri),
           let qureyItems = components.queryItems {
            return qureyItems.reduce(into: [:]) { result, item in
                result[item.name] = item.value
            }
        } else {
            return nil
        }
    }
}

extension NotificationViewController {
    private func navigateToShop(shopId: Int) {
        let shopDetailViewController = makeShopSummaryViewController(shopId: shopId)
        navigationController?.pushViewController(shopDetailViewController, animated: true)
    }
    
    private func navigateToDining() {
        let viewController = makeDiningViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToChat(articleId: Int, chatRoomId: Int) {
        let viewModel = LostItemChatViewModel(articleId: articleId, chatRoomId: chatRoomId, articleTitle: nil)
        let viewController = LostItemChatViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToCallVanData(postId: Int) {
        let viewController = makeCallVanDataViewController(postId: postId)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToCallVanChat(postId: Int) {
        let viewController = makeCallVanChatViewController(postId: postId)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToLostItemData(lostItemId: Int) {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let chatRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let fetchLostItemDataUseCase = DefaultFetchLostItemDataUseCase(repository: lostItemRepository)
        let fetchLostItemListUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
        let changeLostItemStateUseCase = DefaultChangeLostItemStateUseCase(repository: lostItemRepository)
        let deleteLostItemUseCase = DefaultDeleteLostItemUseCase(repository: lostItemRepository)
        let createChatRoomUseCase = DefaultLostItemCreateChatRoomUseCase(chatRepository: chatRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = LostItemDataViewModel(
            checkLoginUseCase: checkLoginUseCase,
            fetchLostItemDataUseCase: fetchLostItemDataUseCase,
            fetchLostItemListUseCase: fetchLostItemListUseCase,
            changeLostItemStateUseCase: changeLostItemStateUseCase,
            deleteLostItemUseCase: deleteLostItemUseCase,
            createChatRoomUseCase: createChatRoomUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            id: lostItemId)
        let viewController = LostItemDataViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func navigateToKeyword(boardId: Int, noticeId: Int) {
        let viewController = makeNoticeDataViewController(noticeId: noticeId, boardId: boardId)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func makeCallVanDataViewController(postId: Int) -> CallVanDataViewController {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let fetchCallVanDataUseCase = DefaultFetchCallVanDataUseCase(repository: callVanRepository)
        let fetchCallVanNotificationListUseCase = DefaultFetchCallVanNotificationListUseCase(repository: callVanRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = CallVanDataViewModel(
            postId: postId,
            fetchCallVanDataUseCase: fetchCallVanDataUseCase,
            fetchCallVanNotificationListUseCase: fetchCallVanNotificationListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        return CallVanDataViewController(viewModel: viewModel)
    }
    
    private func makeCallVanChatViewController(postId: Int) -> CallVanChatViewController {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let coreRepository = DefaultCoreRepository(service: DefaultCoreService())
        let fetchCallVanChatUseCase = DefaultFetchCallVanChatUseCase(repository: callVanRepository)
        let postCallVanChatUseCase = DefaultPostCallVanChatUseCase(repository: callVanRepository)
        let fetchCallVanDataUseCase = DefaultFetchCallVanDataUseCase(repository: callVanRepository)
        let uploadFileUseCase = DefaultUploadFileUseCase(coreRepository: coreRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = CallVanChatViewModel(
            postId: postId,
            fetchCallVanChatUseCase: fetchCallVanChatUseCase,
            postCallVanChatUseCase: postCallVanChatUseCase,
            fetchCallVanDataUseCase: fetchCallVanDataUseCase,
            uploadFileUseCase: uploadFileUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        return CallVanChatViewController(viewModel: viewModel)
    }
    
    private func makeNoticeDataViewController(noticeId: Int, boardId: Int) -> NoticeDataViewController {
        let service = DefaultNoticeService()
        let repository = DefaultNoticeListRepository(service: service)
        let viewModel = NoticeDataViewModel(
            fetchNoticeDataUseCase: DefaultFetchNoticeDataUseCase(noticeListRepository: repository),
            fetchHotNoticeArticlesUseCase: DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository),
            downloadNoticeAttachmentUseCase: DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())),
            noticeId: noticeId,
            boardId: boardId
        )
        return NoticeDataViewController(viewModel: viewModel)
    }
    
    private func makeDiningViewController() -> DiningViewController {
        let diningService = DefaultDiningService()
        let shareService = KakaoShareService()
        let diningRepository = DefaultDiningRepository(diningService: diningService, shareService: shareService)
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let dateProvider = DefaultDateProvider()
        let shareMenuListUseCase = DefaultShareMenuListUseCase(diningRepository: diningRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewModel = DiningViewModel(
            fetchDiningListUseCase: fetchDiningListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            dateProvder: dateProvider,
            shareMenuListUseCase: shareMenuListUseCase,
            changeNotiUseCase: changeNotiUseCase,
            fetchNotiListUsecase: fetchNotiListUseCase,
            changeNotiDetailUseCase: changeNotiDetailUseCase
        )
        let viewController = DiningViewController(viewModel: viewModel)
        viewController.title = "식단"
        return viewController
    }
    
    private func makeShopSummaryViewController(shopId: Int) -> UIViewController {
        let repository = DefaultShopRepository(service: DefaultShopService())
        let fetchOrderShopSummaryFromShopUseCase = DefaultFetchOrderShopSummaryFromShopUseCase(repository: repository)
        let fetchOrderShopMenusAndGroupsFromShopUseCase = DefaultFetchOrderShopMenusAndGroupsFromShopUseCase(shopRepository: repository)
        let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: repository)
        let fetchShopEventListUseCase = DefaultFetchShopEventListUseCase(shopRepository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let viewModel = ShopSummaryViewModel(
            fetchOrderShopSummaryFromShopUseCase: fetchOrderShopSummaryFromShopUseCase,
            fetchOrderShopMenusAndGroupsFromShopUseCase: fetchOrderShopMenusAndGroupsFromShopUseCase,
            fetchShopDataUseCase: fetchShopDataUseCase,
            fetchShopEventListUseCase: fetchShopEventListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            shopId: shopId,
            shopName: nil
        )
        return ShopSummaryViewController(viewModel: viewModel)
    }
}

// MARK: - Action

private extension NotificationViewController {
    @objc func rightBarButtonItemTapped() {
        showPopUpView()
    }
    
    private func showPopUpView() {
        let popUpViewController = NotificationPopUpViewController(
            markAllAsRead: { [weak self] in
                self?.inputSubject.send(.markAllAsRead)
                self?.notificationListView.markAllAsRead()
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.notificationListReadAll, .click, "모두 읽음으로 표시"))
            },
            deleteAll: { [weak self] in
                self?.inputSubject.send(.deleteAllNotifications)
                self?.notificationListView.deleteAll()
                self?.showToastMessage(message: "알림이 삭제되었습니다.")
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.notificationListDeleteAll, .click, "알림 전체 삭제"))
            }
        )
        popUpViewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(
            popUpViewController,
            animated: false
        )
    }
}

// MARK: - Configure

private extension NotificationViewController {
    private func configureNavigationBar() {
        
        let rightBarButtonItem = UIBarButtonItem(
            image: .appImage(asset: .threeCircle),
            style: .plain,
            target: self,
            action: #selector(rightBarButtonItemTapped)
        )
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.ColorSystem.Neutral.gray0
    }
    
    private func setUpLayouts() {
        view.addSubview(notificationListView)
    }
    
    private func setUpConstraints() {
        notificationListView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
