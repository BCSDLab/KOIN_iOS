//
//  HomeTabBarController.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import Combine
import SnapKit
import UIKit

@MainActor
final class HomeTabBarController: UITabBarController {
    
    // MARK: - Layout
    private enum Layout {
        static let TabBarBaseHeight: CGFloat = 52
        static let TabBarCornerRadius: CGFloat = 16
    }
    private var additionalBottomInset: CGFloat {
        Layout.TabBarBaseHeight + TabBarAdditionalHeight - Layout.TabBarCornerRadius
    }
    private var TabBarAdditionalHeight: CGFloat {
        view.safeAreaInsets.bottom < 0.5 ? 6 : 0
    }
    private var TabBarBottomPadding: CGFloat {
        view.safeAreaInsets.bottom < 0.5 ? 6 : view.safeAreaInsets.bottom
    }
    
    // MARK: - Properties
    private let viewModel: HomeTabBarViewModel
    private let inputSubject = PassthroughSubject<HomeTabBarViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let items: [HomeTabBarItem]

    // MARK: - UI Components
    private lazy var homeTabBar = HomeTabBar(tabs: items.map(\.tab)) { [weak self] tag in
        self?.handleTabSelection(tag: tag)
        self?.makeLogEvent(tag: tag)
    }
    
    // MARK: - Initializer
    init(
        items: [HomeTabBarItem],
        viewModel: HomeTabBarViewModel
    ) {
        self.items = items
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        bind()
        setUpObserver()
        setUpViewControllers()
        setUpTabBar()
        if let firstTab = items.first?.tab {
            selectTab(index: firstTab.rawValue)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.checkNotification)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAdditionalBottomInset()
        updateTabBarLayout()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateAdditionalBottomInset()
        updateTabBarLayout()
    }
    
    // MARK: - Bind
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .hasUnreadNotifications(let hasUnreadNotifications):
                    self?.configureRightBarButton(hasUnreadNotifications: hasUnreadNotifications)
                }
            }
            .store(in: &subscriptions)
    }
}

extension HomeTabBarController {
    private func setUpObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("Notification Read"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.inputSubject.send(.checkNotification)
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("Notification Sent"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.configureRightBarButton(hasUnreadNotifications: true)
        }
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.inputSubject.send(.checkNotification)
            }
            .store(in: &subscriptions)
    }
}

extension HomeTabBarController {
    private func setUpViewControllers() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: HomeLogoView())
        self.viewControllers = items.map(\.viewController)
    }

    private func setUpTabBar() {
        view.addSubview(homeTabBar)
        homeTabBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(Layout.TabBarBaseHeight + TabBarBottomPadding)
        }
    }
    
    private func configureNavigationBar(tab: HomeTab) {
        switch tab {
        case .home, .category, .profile:
            configureNavigationBar(style: .newBackground)
        case .board:
            configureNavigationBar(style: .empty)
        }
    }
}

extension HomeTabBarController {
    
    private func configureRightBarButton(hasUnreadNotifications hasDot: Bool = false) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .appImage(asset: hasDot ? .homeBellDot : .homeBell)?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(rightBarButtonTapped)
        )
    }
    
    @objc private func rightBarButtonTapped() {
        inputSubject.send(.logEvent(
            EventParameter.EventLabel.Home.DA2.mainMainNotificationListEntryClick,
            "알림 아이콘"
        ))
        navigateToNotification()
    }
    
    private func navigateToNotification() {
        let notificatioHistoryRepository = DefaultNotificationHistoryRepository(service: DefaultNotificationHistoryService())
        let fetchNotificationHistoryUseCase = DefaultFetchNotificationHistoryUseCase(notificationHistoryRepository: notificatioHistoryRepository)
        let deleteNotificationHistoryUseCase = DefaultDeleteNotificationHistoryUseCase(repository: notificatioHistoryRepository)
        let updateNotificationHistoryUseCase = DefaultUpdateNotificationHistoryUseCase(repository: notificatioHistoryRepository)
        
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NotificationViewModel(
            fetchNotificationHistoryUseCase: fetchNotificationHistoryUseCase,
            deleteNotificationHistoryUseCase: deleteNotificationHistoryUseCase,
            updateNotificationHistoryUseCase: updateNotificationHistoryUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let viewController = NotificationViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HomeTabBarController {
    private func updateAdditionalBottomInset() {
        items.map(\.viewController).forEach {
            $0.additionalSafeAreaInsets.bottom = additionalBottomInset
        }
    }
    
    private func updateTabBarLayout() {
        homeTabBar.snp.updateConstraints {
            $0.height.equalTo(Layout.TabBarBaseHeight + TabBarBottomPadding)
        }
    }
}

extension HomeTabBarController {

    private func handleTabSelection(tag: Int) {
        guard let index = items.firstIndex(where: { $0.tab.rawValue == tag }) else {
            return
        }
        selectTab(index: index)
    }

    private func selectTab(index: Int) {
        configureNavigationBar(tab: items[index].tab)
        homeTabBar.select(tab: items[index].tab)
        UIView.performWithoutAnimation {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            selectedIndex = index
            view.layoutIfNeeded()
            CATransaction.commit()
        }
    }
    
    private func makeLogEvent(tag: Int) {
        if let tab = HomeTab.init(rawValue: tag) {
            inputSubject.send(.logEvent(tab.logLabel, tab == .board ? "공지사항" : tab.title))
        }
    }
}
