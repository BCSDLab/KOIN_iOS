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
        setUpViewControllers()
        if let firstTab = items.first?.tab {
            selectTab(index: firstTab.rawValue)
        }
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
}

extension HomeTabBarController {
    private func setUpViewControllers() {
        let configuredViewControllers = items.map { configuration in
            let tabBar = HomeTabBar(
                tabs: items.map(\.tab),
                selectedTab: configuration.tab
            ) { [weak self] tag in
                self?.handleTabSelection(tag: tag)
            }
            tabBars.append(tabBar)
            let rootViewController = configuration.viewController.then {
                $0.view?.addSubview(tabBar)
                tabBar.snp.makeConstraints {
                    $0.leading.trailing.bottom.equalToSuperview()
                    $0.height.equalTo(Layout.TabBarBaseHeight + TabBarBottomPadding)
                }
            }
            return CustomNavigationController(rootViewController: rootViewController)
        }
        viewControllers = configuredViewControllers
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
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .sink { _ in }
            .store(in: &subscriptions)
    }

    private func handleTabSelection(tag: Int) {
        guard let index = items.firstIndex(where: { $0.tab.rawValue == tag }) else {
            return
        }
        
        if let homeTab = HomeTab(rawValue: tag) {
            inputSubject.send(.logEvent(homeTab.logLabel, .click, homeTab.title))
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
}
