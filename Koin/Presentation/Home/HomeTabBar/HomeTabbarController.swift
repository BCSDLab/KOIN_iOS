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
    private var tabBars: [HomeTabBar] = []
    
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
        let viewControllers = setUpTabBar(items: items)
        configureNavigationBar(viewControllers: viewControllers)
        self.viewControllers = viewControllers.map { CustomNavigationController(rootViewController: $0) }
    }
    
    private func setUpTabBar(items: [HomeTabBarItem]) -> [UIViewController] {
        items.map { configuration in
            let tabBar = HomeTabBar(
                tabs: items.map(\.tab),
                selectedTab: configuration.tab
            ) { [weak self] tag in
                self?.handleTabSelection(tag: tag)
                self?.makeLogEvent(tag: tag)
            }
            
            tabBars.append(tabBar)
            
            let rootViewController = configuration.viewController.then {
                $0.view?.addSubview(tabBar)
                tabBar.snp.makeConstraints {
                    $0.leading.trailing.bottom.equalToSuperview()
                    $0.height.equalTo(Layout.TabBarBaseHeight + TabBarBottomPadding)
                }
            }
            
            return rootViewController
        }
    }
    
    private func configureNavigationBar(viewControllers: [UIViewController]) {
        var viewControllers = viewControllers
        
        for index in items.indices {
            var navigationBarStyle: NavigationBarStyle
            switch items[index].tab {
            case .home, .category, .profile:
                navigationBarStyle = .newBackground
            case .board:
                navigationBarStyle = .empty
            }
            
            viewControllers[index].configureNavigationBar(style: navigationBarStyle)
        }
        
        viewControllers.forEach { viewController in
            configureLeftBarItem(viewController: viewController)
        }
    }
    
    private func configureLeftBarItem(viewController: UIViewController) {
        let viewController = viewController
        let leftBarButtonItem = UIBarButtonItem(customView: HomeLogoView())
        viewController.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
}

extension HomeTabBarController {
    
    private func configureRightBarButton(hasUnreadNotifications hasDot: Bool = false) {
        viewControllers?.forEach { navigationController in
            guard let rootViewController = (navigationController as? UINavigationController)?.viewControllers.first else {
                return
            }
            let rightBarButtonItem = UIBarButtonItem(
                image: .appImage(asset: hasDot ? .homeBellDot : .homeBell)?.withRenderingMode(.alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(rightBarButtonTapped)
            )
            rootViewController.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    @objc private func rightBarButtonTapped() {
        inputSubject.send(.logEvent(
            EventParameter.EventLabel.Campus.notification,
            .click,
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
        (selectedViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
    }
}

extension HomeTabBarController {
    private func updateAdditionalBottomInset() {
        items.map(\.viewController).forEach {
            $0.additionalSafeAreaInsets.bottom = additionalBottomInset
        }
    }
    
    private func updateTabBarLayout() {
        tabBars.forEach {
            $0.snp.remakeConstraints {
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(Layout.TabBarBaseHeight + TabBarBottomPadding)
            }
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
            inputSubject.send(.logEvent(tab.logLabel, .click, tab.title))
        }
    }
}
